class RenameReturnDetailsReasonTypeReason < ActiveRecord::Migration[7.0]
  def change
    change_table :return_details do |t|
      t.rename :reason_type, :reason
    end
  end
end
