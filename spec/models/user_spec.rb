require 'rails_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'can_favorite'
end