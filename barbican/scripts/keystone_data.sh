export OS_SERVICE_TOKEN=ADMIN_TOKEN
export OS_SERVICE_ENDPOINT="http://localhost:35357/v2.0"

# Create admin account
keystone user-create --name=admin --pass=password --email=admin@example.com
keystone tenant-create --name=admin --description="Admin Tenant"
keystone role-create --name=admin
keystone user-role-add --user=admin --tenant=admin --role=admin

# Create service user
keystone user-create --name=barbican --pass=secretservice --email=barbican@example.com
keystone tenant-create --name=service --description="Service Tenant"
keystone user-role-add --user=barbican --tenant=service --role=admin

# Create RBAC users
keystone user-create --name=admin_user --pass=password --email=admin@example.com
keystone user-create --name=creator_user --pass=password --email=creator@example.com
keystone user-create --name=observer_user --pass=password --email=observer@example.com
keystone user-create --name=audit_user --pass=password --email=audit@example.com

keystone tenant-create --name=demo --description="Demo Tenant"

keystone role-create --name=creator
keystone role-create --name=observer
keystone role-create --name=audit

keystone user-role-add --user=admin_user --tenant=demo --role=admin
keystone user-role-add --user=creator_user --tenant=demo --role=creator
keystone user-role-add --user=observer_user --tenant=demo --role=observer
keystone user-role-add --user=audit_user --tenant=demo --role=audit

keystone service-create --name barbican --type 'key-manager'
keystone endpoint-create --service barbican --publicurl 'http://localhost:9311'

