# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  discussion_id  :integer
#  text           :text
#  response_to_id :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :comment do
    discussion nil
text "MyText"
response_to 1
user nil
  end

end
