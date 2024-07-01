class CreateManagersSatisfactions < ActiveRecord::Migration[7.0]
  def up
    SharedSatisfaction.find_each do |satisfaction|
      satisfaction.company_satisfaction.share
    end
  end
end
