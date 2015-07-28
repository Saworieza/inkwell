require 'spec_helper'

describe 'Favorited item' do
  before :each do
    @user = User.create!
    @post = Post.create! user: @user
  end

  before :each, with_company: true do
    @company = Company.create!
  end

  before :each, with_favorited_post: true do
    @post_1 = Post.create! user: @user
    @user.favorite(@post_1)
  end

  it 'should be created' do
    expect(@user.favorite?(@post)).to eq(false)
    @user.favorite(@post)
    expect(@user.favorite?(@post)).to eq(true)
  end

  it 'should be destroyed', with_favorited_post: true do
    expect(@user.favorite?(@post_1)).to eq(true)
    @user.unfavorite(@post_1)
    expect(@user.favorite?(@post)).to eq(false)
  end

  it 'should be exists', with_favorited_post: true do
    expect(@user.favorite?(@post_1)).to eq(true)
  end

  it 'should not be exists' do
    expect(@user.favorite?(@post)).to eq(false)
  end

  it 'operations should be chained', with_company: true do
    @user.favorite(@post).favorite(@company)
    expect(@user.favorite?(@post)).to eq(true)
    expect(@user.favorite?(@company)).to eq(true)
  end

  describe 'favorites' do
    before :each do
      @other_user = User.create!
      ((0...20).to_a.map{|i| Post.create! user: @user, created_at: Time.now - i.minutes} +
          (0...20).to_a.map{|i| Company.create! created_at: Time.now - i.minutes}).each do |obj|
        @user.favorited_items.create!(favorited: obj, created_at: obj.created_at)
        @other_user.favorite(obj)
      end
    end

    it 'should return objects' do
      result = @user.favorites
      expect(result.size).to eq(10)
      expect(result.select{|r| r.is_a?(Post)}.size).to eq(5)
      expect(result.select{|r| r.is_a?(Company)}.size).to eq(5)
    end

    it 'should return only this user objects' do
      expect(@user.favorites(per_page: 100).size).to eq(40)
    end

    describe 'pagination' do
      it 'should return objects with default params' do
        expect(@user.favorites.size).to eq(10)
      end

      it 'should return objects with custom page' do
        result = @user.favorites(page: 2)
        expect(result.size).to eq(10)
        expect((result + @user.favorites).uniq.size).to eq(20)
      end

      it 'should return objects with custom per page' do
        expect(@user.favorites(per_page: 20).size).to eq(20)
      end
    end
  end

end