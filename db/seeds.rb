puts "creating some default severities"
Severity.create :position => 6, :name => "Normal"
Severity.create :position => 5, :name => "Minor"
Severity.create :position => 4, :name => "Enhancement"
Severity.create :position => 3, :name => "Major"
Severity.create :position => 2, :name => "Critical"
Severity.create :position => 1, :name => "Blocker"

puts "Creating some default status"
Status.create :id => 1, :name => "Open"
Status.create :id => 2, :name => "Fixed"
Status.create :id => 3, :name => "Duplicate"
Status.create :id => 4, :name => "Invalid"
Status.create :id => 5, :name => "WorksForMe"
Status.create :id => 6, :name => "WontFix"

puts "Creating default public user"
u = User.create(:login => 'Public',
            :password => 'public',
            :password_confirmation => 'public',
            :view_changesets => 1,
            :view_code => 1,
            :view_milestones => 1,
            :view_tickets => 1,
            :create_tickets => 1,
            :admin => 0 )

puts "Creating default admin"
u = User.create(:login => 'admin',
            :password => 'admin',
            :password_confirmation => 'admin',
            :view_changesets => 1,
            :view_code => 1,
            :view_milestones => 1,
            :view_tickets => 1,
            :create_tickets => 1,
            :admin => 1 )
