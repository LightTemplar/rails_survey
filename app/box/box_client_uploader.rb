class BoxClientUploader
  attr_accessor :private_key, :user_access_token, :box_client

  def initialize
    @private_key = OpenSSL::PKey::RSA.new(File.read(ENV['JWT_PRIVATE_KEY_PATH']), ENV['JWT_PRIVATE_KEY_PASSWORD'])
    box_user_token
    get_box_client
  end

  def box_user_token
    response = Boxr.get_user_token(ENV['BOX_USER_ID'], private_key: @private_key, private_key_password: ENV['JWT_PRIVATE_KEY_PASSWORD'], public_key_id: ENV['JWT_PUBLIC_KEY_ID'], client_id: ENV['BOX_CLIENT_ID'], client_secret: ENV['BOX_CLIENT_SECRET'])
    @user_access_token = response.access_token
  end

  def get_box_client
    @box_client = Boxr::Client.new(@user_access_token, client_id: ENV['BOX_CLIENT_ID'], client_secret: ENV['BOX_CLIENT_SECRET'], enterprise_id: ENV['BOX_ENTERPRISE_ID'], jwt_private_key: @private_key, jwt_private_key_password: ENV['JWT_PRIVATE_KEY_PASSWORD'], jwt_public_key_id: ENV['JWT_PUBLIC_KEY_ID'])
  end

  def box_folder
    @box_client.folder_from_id(ENV['BOX_FOLDER_ID'])
  end

  def upload_file(path_to_file, destination_folder = box_folder, filename = nil)
    @box_client.upload_file(path_to_file, destination_folder, preflight_check: true, send_content_md5: true, name: filename)
  end

  def folder_with_name(name)
    @box_client.folder_items(box_folder).select { |f| f.type == 'folder' && f.name == name }.first
  end

  def create_folder(name)
    @box_client.create_folder(name, box_folder) unless folder_with_name(name)
  end
end
