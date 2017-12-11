class CriticalSpares < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'UNIQUEPARTID'
end
class CriticalSparesChanges < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'cop_id'
end
class CriticalSparesChangeHistory < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'cop_id'
end
