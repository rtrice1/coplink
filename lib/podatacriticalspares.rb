class PodataCriticalSpares < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'podata_id'
end
class PodataCriticalSparesChanges < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'cop_id'
end
class PodataCriticalSparesChangeHistory < ActiveRecord::Base
  include ActiveRecord::Diff
  self.primary_key = 'cop_id'
end
