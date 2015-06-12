# == Schema Information
#
# Table name: documents
#
#  id          :integer          not null, primary key
#  folder_id   :integer
#  folder_type :string
#  name        :string(50)
#  content     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Document < ActiveRecord::Base
  has_paper_trail on: [:update, :destroy]

  belongs_to :folder, polymorphic: true

  default_scope { order('created_at') }

  def as_html
    Nokogiri::HTML(content)
  end

  def as_javascript
     ExecJS.compile(content)
  end

  def as_json(options)
    super(options.merge(only: [:id, :name, :content]))
  end
end
