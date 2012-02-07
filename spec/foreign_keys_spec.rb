describe 'Foreign keys' do
  describe '#add_foreign_key' do

    it 'adds foreign key' do
      PgCommentGetter.has_foreign_key?('demography.citizens', :user_id).should == true
    end

  end
end