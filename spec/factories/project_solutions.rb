# == Schema Information
#
# Table name: project_solutions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  repository :string
#  url        :string
#  summary    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :integer
#
# Indexes
#
#  index_project_solutions_on_project_id  (project_id)
#  index_project_solutions_on_user_id     (user_id)
#

FactoryGirl.define do
  factory :project_solution do
    repository 'makeitrealcamp/start'
    url { Faker::Internet.url }
    summary { Faker::Lorem.paragraph }
    association  :user, factory: :user
    association  :project, factory: :project
  end
end
