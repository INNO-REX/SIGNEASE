# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

Signease.Seeds.SetUser.run()
Signease.Seeds.SetTestNotifications.run()

# Create learning programs and courses
Signease.Seeds.SetLearning.run()
