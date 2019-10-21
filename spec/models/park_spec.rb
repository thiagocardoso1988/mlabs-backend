require 'rails_helper'

RSpec.describe Park, type: :model do
  it { should validate_presence_of(:plate) }
  it { should allow_value('AAA-0000').for(:plate) }
  it { should allow_value('zzz-9999').for(:plate) }
  it { should_not allow_value('AAA0000').for(:plate) }
  it { should_not allow_value('zzz9999').for(:plate) }
end