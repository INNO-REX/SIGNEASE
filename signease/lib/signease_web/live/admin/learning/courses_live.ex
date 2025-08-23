defmodule SigneaseWeb.Admin.Learning.CoursesLive do
  use SigneaseWeb, :live_view

  alias Signease.Learning
  alias Signease.Learning.Course
  alias Signease.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Course Management")
     |> assign(:courses, [])
     |> assign(:show_form, false)
     |> assign(:editing_course, nil)
     |> assign(:course, %Course{})
     |> assign(:courses, Learning.list_courses())
     |> assign(:programs, Learning.list_active_programs())
     |> assign(:instructors, Accounts.list_users_by_type("INSTRUCTOR")),
     temporary_assigns: [courses: []]}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    course = Learning.get_course_with_program_and_instructor!(id)
    {:noreply, assign(socket, :course, course)}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_course, nil)
     |> assign(:course, %Course{})}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    course = Learning.get_course!(id)
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_course, course)
     |> assign(:course, course)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:editing_course, nil)
     |> assign(:course, %Course{})}
  end

  @impl true
  def handle_event("save", %{"course" => course_params}, socket) do
    save_course(socket, socket.assigns.editing_course, course_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Learning.get_course!(id)
    {:ok, _} = Learning.delete_course(course, socket.assigns.current_user.id)

    {:noreply,
     socket
     |> put_flash(:info, "Course deleted successfully")
     |> assign(:courses, Learning.list_courses())}
  end

  @impl true
  def handle_event("assign-instructor", %{"course-id" => course_id, "instructor-id" => instructor_id}, socket) do
    case Learning.assign_instructor_to_course(course_id, instructor_id, socket.assigns.current_user.id) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor assigned successfully")
         |> assign(:courses, Learning.list_courses())}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to assign instructor")}
    end
  end

  defp save_course(socket, %Course{} = course, course_params) do
    case Learning.update_course(course, course_params) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course updated successfully")
         |> assign(:show_form, false)
         |> assign(:editing_course, nil)
         |> assign(:course, %Course{})
         |> assign(:courses, Learning.list_courses())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :course, changeset)}
    end
  end

  defp save_course(socket, nil, course_params) do
    case Learning.create_course(course_params) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course created successfully")
         |> assign(:show_form, false)
         |> assign(:course, %Course{})
         |> assign(:courses, Learning.list_courses())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :course, changeset)}
    end
  end
end
