class Relationship < ActiveRecord::Base
  # `foreign_key`はデフォルトでは`<クラス名(小文字)>_id`
  # 外部キーは`user_id`なので、ここでは指定する必要はない
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
end
