ActiveAdmin.register AndroidUpdate do
  menu if: proc { current_user.super_admin? }
  permit_params :version, :name, :apk_update

  form do |f|
    f.inputs 'Android APK Details' do
      f.input :version, label: 'Version (corresponds to android:versionCode)'
      f.input :name, label: 'Name (corresponds to android:versionName)'
      f.input :apk_update, as: :file
    end
    f.actions
  end
end
