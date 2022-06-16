class UsersRoles < ActiveRecord::Base

    def self.delete_role(subject,role_symbol, obj=nil)
        res_name = obj.nil? ? nil : obj.class.name
        res_id   = obj.id rescue nil
        role_row = subject.roles.where(name: role_symbol.to_s, resource_type: res_name , resource_id: res_id).first
        if  role_row.nil?
            raise "cannot delete nonexisting role on subject"
        end
        role_id = role_row.id
        self.delete_all(user_id: subject.id,role_id: role_id)
    end

    private_class_method :new
end
