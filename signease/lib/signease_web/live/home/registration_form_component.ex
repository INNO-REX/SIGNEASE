defmodule SigneaseWeb.Home.RegistrationFormComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts
  alias Signease.Repo
  alias Signease.Accounts.User
  import SigneaseWeb.Components.LoaderComponent

  def render(assigns) do
    ~H"""
    <div class="relative">
      <.loader id="auth-loader" />

      <div class="relative transform transition-all duration-700 ease-out hover:scale-105">
      <!-- Form Container for Smooth Transitions -->
      <div class="relative" style="min-height: 500px;">
        <!-- Glassmorphism Background -->
        <div class="absolute inset-0 bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-xl rounded-2xl border border-white/20 shadow-2xl transition-all duration-500 hover:shadow-3xl hover:border-white/30"></div>

        <!-- Animated Background Elements -->
        <div class="absolute inset-0 overflow-hidden rounded-2xl">
          <div class="absolute -top-10 -right-10 w-20 h-20 bg-blue-500/20 rounded-full blur-xl animate-pulse"></div>
          <div class="absolute -bottom-10 -left-10 w-16 h-16 bg-purple-500/20 rounded-full blur-xl animate-ping"></div>
          <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-32 h-32 bg-gradient-to-r from-blue-400/10 to-purple-400/10 rounded-full blur-2xl animate-spin" style="animation-duration: 20s;"></div>
        </div>

        <!-- Form Content -->
        <div class="relative z-10 p-8">
          <!-- Dynamic Header with Slow, Smooth Animations -->
          <div class="text-center mb-8 transform transition-all duration-1000 ease-out">
            <h2 class="text-3xl font-bold text-white mb-2 transform transition-all duration-1200 ease-out hover:scale-105 hover:text-blue-300"
                style="transition: all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);">
              <%= case @form_state do %>
                <% "login" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.2s;">Welcome Back</span>
                <% "signup" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.2s;">Join Our Learning Community</span>
                <% "forgot_password" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.2s;">Reset Password</span>
              <% end %>
            </h2>
            <p class="text-gray-200 transform transition-all duration-1000 ease-out hover:text-white"
               style="transition: all 1.0s cubic-bezier(0.25, 0.46, 0.45, 0.94);">
              <%= case @form_state do %>
                <% "login" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.4s;">Sign in to your account</span>
                <% "signup" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.4s;">Create your learner account to get started</span>
                <% "forgot_password" -> %>
                  <span class="inline-block animate-fade-in-up" style="animation-delay: 0.4s;">Enter your email to receive reset instructions</span>
              <% end %>
            </p>
          </div>

          <!-- Success/Error Messages -->
          <%= if @message do %>
            <div class={if @message_type == "error", do: "bg-red-500/20 border-red-400/50", else: "bg-green-500/20 border-green-400/50"}
                 class="mb-6 p-4 rounded-xl border backdrop-blur-sm animate-fade-in-up">
              <p class={if @message_type == "error", do: "text-red-200", else: "text-green-200"} class="text-sm font-medium">
                <%= @message %>
              </p>
            </div>
          <% end %>

          <!-- Login Form with Smooth Transitions -->
          <div class={if @form_state == "login", do: "form-visible", else: "form-hidden"}
               style="transition: all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94); transform-origin: center;">
            <form phx-submit="login-submit" phx-target={@myself} class="space-y-6">
              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 0.6s;">
                <label for="login_username" class="block text-sm font-medium text-white/90">Username</label>
                <div class="relative group">
                  <input type="text" id="login_username" name="username" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your username">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 0.8s;">
                <label for="login_password" class="block text-sm font-medium text-white/90">Password</label>
                <div class="relative group">
                  <input type="password" id="login_password" name="password" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your password">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Submit Button with Enhanced Animation -->
              <div class="relative mt-8 animate-fade-in-up" style="animation-delay: 1.0s;">
                <button type="submit"
                        class="w-full relative px-6 py-4 bg-gradient-to-r from-blue-600/80 to-purple-600/80 text-white font-semibold rounded-xl hover:from-blue-500/90 hover:to-purple-500/90 transition-all duration-500 shadow-lg backdrop-blur-sm border border-white/20 overflow-hidden group transform hover:scale-105 hover:shadow-2xl">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                  <div class="absolute inset-0 bg-gradient-to-r from-blue-400/20 to-purple-400/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                  <span class="relative z-10 flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2 transform group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
                    </svg>
                    Sign In
                  </span>
                </button>
              </div>
            </form>

            <!-- Login Form Links with Enhanced Animations -->
            <div class="mt-6 text-center space-y-3 animate-fade-in-up" style="animation-delay: 1.2s;">
              <button phx-click="switch-to-forgot-password" phx-target={@myself}
                      class="block w-full text-sm text-blue-300 hover:text-blue-200 font-medium transition-all duration-300 transform hover:scale-105 hover:translate-x-1">
                <span class="flex items-center justify-center">
                  <svg class="w-4 h-4 mr-2 transform group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                  Forgot your password?
                </span>
              </button>
              <p class="text-sm text-white/70">
                Don't have an account?
                <button phx-click="switch-to-signup" phx-target={@myself}
                        class="text-blue-300 hover:text-blue-200 font-medium transition-all duration-300 transform hover:scale-105 hover:translate-x-1">
                  <span class="flex items-center">
                    Sign up here
                    <svg class="w-4 h-4 ml-1 transform group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                    </svg>
                  </span>
                </button>
              </p>
            </div>
          </div>

          <!-- Signup Form with Smooth Transitions -->
          <div class={if @form_state == "signup", do: "form-visible", else: "form-hidden"}
               style="transition: all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94); transform-origin: center;">
            <form phx-submit="signup-submit" phx-target={@myself} class="space-y-6">
              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 0.6s;">
                <label for="signup_first_name" class="block text-sm font-medium text-white/90">First Name</label>
                <div class="relative group">
                  <input type="text" id="signup_first_name" name="first_name" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your first name">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 0.8s;">
                <label for="signup_last_name" class="block text-sm font-medium text-white/90">Last Name</label>
                <div class="relative group">
                  <input type="text" id="signup_last_name" name="last_name" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your last name">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 1.0s;">
                <label for="signup_email" class="block text-sm font-medium text-white/90">Email Address</label>
                <div class="relative group">
                  <input type="email" id="signup_email" name="email" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your email">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 1.2s;">
                <label for="signup_hearing_status" class="block text-sm font-medium text-white/90">Hearing Status</label>
                <div class="relative group">
                  <select id="signup_hearing_status" name="hearing_status" required
                          class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]">
                    <option value="" class="bg-gray-800 text-white">Select your hearing status</option>
                    <option value="HEARING" class="bg-gray-800 text-white">Hearing</option>
                    <option value="DEAF" class="bg-gray-800 text-white">Deaf</option>
                    <option value="HARD_OF_HEARING" class="bg-gray-800 text-white">Hard of Hearing</option>
                  </select>
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 1.4s;">
                <label for="signup_password" class="block text-sm font-medium text-white/90">Password</label>
                <div class="relative group">
                  <input type="password" id="signup_password" name="password" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Create a password (min 8 characters)">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                  </div>
                </div>
                <p class="text-xs text-gray-300 mt-1">Password must be at least 8 characters with uppercase, lowercase, and number</p>
              </div>

              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 1.6s;">
                <label for="signup_password_confirmation" class="block text-sm font-medium text-white/90">Confirm Password</label>
                <div class="relative group">
                  <input type="password" id="signup_password_confirmation" name="password_confirmation" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Confirm your password">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Submit Button with Enhanced Animation -->
              <div class="relative mt-8 animate-fade-in-up" style="animation-delay: 1.8s;">
                <button type="submit"
                        class="w-full relative px-6 py-4 bg-gradient-to-r from-green-600/80 to-blue-600/80 text-white font-semibold rounded-xl hover:from-green-500/90 hover:to-blue-500/90 transition-all duration-500 shadow-lg backdrop-blur-sm border border-white/20 overflow-hidden group transform hover:scale-105 hover:shadow-2xl">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                  <div class="absolute inset-0 bg-gradient-to-r from-green-400/20 to-blue-400/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                  <span class="relative z-10 flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2 transform group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
                    </svg>
                    Create Learner Account
                  </span>
                </button>
              </div>
            </form>

            <!-- Signup Form Links with Enhanced Animations -->
            <div class="mt-6 text-center space-y-3 animate-fade-in-up" style="animation-delay: 2.0s;">
              <p class="text-sm text-white/70">
                Already have an account?
                <button phx-click="switch-to-login" phx-target={@myself}
                        class="text-blue-300 hover:text-blue-200 font-medium transition-all duration-300 transform hover:scale-105 hover:translate-x-1">
                  <span class="flex items-center">
                    Sign in here
                    <svg class="w-4 h-4 ml-1 transform group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                    </svg>
                  </span>
                </button>
              </p>
            </div>
          </div>

          <!-- Forgot Password Form with Smooth Transitions -->
          <div class={if @form_state == "forgot_password", do: "form-visible", else: "form-hidden"}
               style="transition: all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94); transform-origin: center;">
            <form phx-submit="forgot-password-submit" phx-target={@myself} class="space-y-6">
              <div class="space-y-2 animate-fade-in-up" style="animation-delay: 0.6s;">
                <label for="forgot_email" class="block text-sm font-medium text-white/90">Email Address</label>
                <div class="relative group">
                  <input type="email" id="forgot_email" name="email" required
                         class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl focus:ring-2 focus:ring-blue-400 focus:border-transparent text-white placeholder-white/50 backdrop-blur-sm transition-all duration-500 group-hover:bg-white/15 group-hover:border-white/30 transform group-hover:scale-[1.02]"
                         placeholder="Enter your email">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent rounded-xl pointer-events-none transition-all duration-500 group-hover:via-white/10"></div>
                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                    <svg class="w-5 h-5 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Submit Button with Enhanced Animation -->
              <div class="relative mt-8 animate-fade-in-up" style="animation-delay: 0.8s;">
                <button type="submit"
                        class="w-full relative px-6 py-4 bg-gradient-to-r from-orange-600/80 to-red-600/80 text-white font-semibold rounded-xl hover:from-orange-500/90 hover:to-red-500/90 transition-all duration-500 shadow-lg backdrop-blur-sm border border-white/20 overflow-hidden group transform hover:scale-105 hover:shadow-2xl">
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                  <div class="absolute inset-0 bg-gradient-to-r from-orange-400/20 to-red-400/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                  <span class="relative z-10 flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2 transform group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                    Send Reset Link
                  </span>
                </button>
              </div>
            </form>

            <!-- Forgot Password Form Links with Enhanced Animations -->
            <div class="mt-6 text-center space-y-3 animate-fade-in-up" style="animation-delay: 1.0s;">
              <p class="text-sm text-white/70">
                Remember your password?
                <button phx-click="switch-to-login" phx-target={@myself}
                        class="text-blue-300 hover:text-blue-200 font-medium transition-all duration-300 transform hover:scale-105 hover:translate-x-1">
                  <span class="flex items-center">
                    Sign in here
                    <svg class="w-4 h-4 ml-1 transform group-hover:translate-x-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                    </svg>
                  </span>
                </button>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    </div>
    """
  end

  def update(assigns, socket) do
    # Set default values for message and message_type if not provided
    assigns = Map.merge(%{message: nil, message_type: nil}, assigns)
    {:ok, assign(socket, assigns)}
  end

  def handle_event("switch-to-signup", _params, socket) do
    {:noreply, assign(socket, form_state: "signup", message: nil, message_type: nil)}
  end

  def handle_event("switch-to-login", _params, socket) do
    {:noreply, assign(socket, form_state: "login", message: nil, message_type: nil)}
  end

  def handle_event("switch-to-forgot-password", _params, socket) do
    {:noreply, assign(socket, form_state: "forgot_password", message: nil, message_type: nil)}
  end

    def handle_event("login-submit", params, socket) do
    # Show loader via JavaScript
    socket = push_event(socket, "show-loader", %{
      id: "auth-loader",
      message: "Authenticating...",
      subtext: "Please wait while we verify your credentials"
    })

    case authenticate_user(params) do
      {:ok, user} ->
        # Hide loader immediately after successful authentication
        socket = push_event(socket, "hide-loader", %{id: "auth-loader"})

        # Check if user has auto-generated password and needs to change it
        if user.auto_pwd == "Y" do
          # Redirect to force password change with user ID as parameter
          {:noreply, push_navigate(socket, to: "/force-password-change?user_id=#{user.id}")}
        else
          # Redirect users to appropriate dashboard based on their user type
          case user.user_type do
            "ADMIN" ->
              # For admin users, redirect to admin dashboard with user info in URL params
              {:noreply, push_navigate(socket, to: "/admin/dashboard?user_id=#{user.id}")}
            "INSTRUCTOR" ->
              # For instructor users, redirect to lecturer dashboard
              {:noreply, push_navigate(socket, to: "/lecturer/dashboard?user_id=#{user.id}")}
            "LEARNER" ->
              # For learner users, redirect to learner dashboard
              {:noreply, push_navigate(socket, to: "/learner/dashboard?user_id=#{user.id}")}
            _ ->
              # For other user types (SUPPORT, etc.), redirect to home page
              {:noreply, push_navigate(socket, to: "/")}
          end
        end

      {:error, reason} ->
        # Hide loader and show error
        socket = push_event(socket, "hide-loader", %{id: "auth-loader"})
        message = case reason do
          :invalid_credentials -> "Invalid username or password"
          :user_not_found -> "User not found"
          :not_approved -> "Your account is pending approval. Please contact an administrator."
          :disabled -> "Your account has been disabled. Please contact support."
          _ -> "Login failed. Please try again."
        end
        {:noreply, assign(socket, message: message, message_type: "error")}
    end
  end

  def handle_event("signup-submit", params, socket) do
    # Show loader via JavaScript
    socket = push_event(socket, "show-loader", %{
      id: "auth-loader",
      message: "Creating account...",
      subtext: "Please wait while we set up your account"
    })

    case Accounts.register_learner(params) do
      {:ok, _user} ->
        # Hide loader and show success message
        socket = push_event(socket, "hide-loader", %{id: "auth-loader"})
        message = "Account created successfully! Please wait for admin approval before you can sign in."
        {:noreply, assign(socket, message: message, message_type: "success")}

      {:error, changeset} ->
        # Hide loader and show error
        socket = push_event(socket, "hide-loader", %{id: "auth-loader"})
        message = format_changeset_errors(changeset)
        {:noreply, assign(socket, message: message, message_type: "error")}
    end
  end

  def handle_event("forgot-password-submit", params, socket) do
    # TODO: Implement forgot password logic
    IO.inspect(params, label: "Forgot password params")
    {:noreply, socket}
  end

  # Private functions

      defp authenticate_user(%{"username" => username, "password" => password}) do
    IO.puts("=== LOGIN ATTEMPT ===")
    IO.puts("Username/Email: #{username}")
    IO.puts("Password: #{password}")

    # Try to find user by username first, then by email
    user = case Accounts.get_user_by_username(username) do
      nil ->
        # If not found by username, try by email
        IO.puts("User not found by username, trying email...")
        Repo.get_by(User, email: username)
      user ->
        user
    end

    IO.puts("User found: #{inspect(user)}")

    case user do
      nil ->
        IO.puts("User not found by username or email")
        {:error, :user_not_found}
      user ->
        # Check password and user status
        IO.puts("User found: #{inspect(user)}")
        cond do
          not User.valid_password?(user, password) ->
            IO.puts("Invalid password")
            {:error, :invalid_credentials}
          not user.approved ->
            IO.puts("User not approved")
            {:error, :not_approved}
          user.disabled ->
            IO.puts("User disabled")
            {:error, :disabled}
          true ->
            IO.puts("Login successful")
            {:ok, user}
        end
    end
  end

  defp authenticate_user(_), do: {:error, :invalid_credentials}

  defp format_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join(", ", fn {_field, errors} ->
      Enum.join(errors, ", ")
    end)
  end


end
