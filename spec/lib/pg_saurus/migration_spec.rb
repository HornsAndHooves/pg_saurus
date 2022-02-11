require 'spec_helper'

describe ActiveRecord::Migration[5.2] do
  let(:conn) { double(:connection) }

  let(:ensure_role_set) { false }

  before do
    allow(PgSaurus.config).
      to receive(:ensure_role_set).and_return(ensure_role_set)
  end

  after { Object.send(:remove_const, :TestMigration) }


  describe "#exec_migration" do
    context "role is set" do
      before do
        class TestMigration < described_class
          set_role "mikki"
        end
      end

      it "executes migration as role" do
        migration = TestMigration.new

        expect(conn).to receive(:execute).with("SET ROLE mikki")
        expect(migration).to receive(:up)
        expect(conn).to receive(:execute).with("RESET ROLE")

        migration.exec_migration(conn, :up)
      end

      context "for data change migration" do
        it "raises an error" do
          expect {
            module SeedMigrator; end

            class TestMigration < described_class
              include SeedMigrator

              set_role "mikki"
            end
          }.to raise_error(PgSaurus::UseKeepDefaultRoleError)
        end
      end
    end

    context "role is not set" do
      before do
        class TestMigration < described_class; end
      end

      context "config.ensure_role_set=true" do
        let(:ensure_role_set) { true }

        it "raises error" do
          migration = TestMigration.new

          expect { migration.exec_migration(conn, :up) }.
            to raise_error(PgSaurus::RoleNotSetError, /TestMigration/)
        end

        context "keep_default_role was called" do
          before do
            module SeedMigrator; end

            class TestMigration < described_class
              include SeedMigrator

              keep_default_role
            end
          end

          it "executes migrations" do
            migration = TestMigration.new

            expect(migration).to receive(:up)
            migration.exec_migration(conn, :up)
          end

          context "for structure change migration" do
            it "raises an error" do
              expect {
                module SeedMigrator; end

                class TestMigrations < described_class
                  keep_default_role
                end
              }.to raise_error(PgSaurus::UseSetRoleError)
            end
          end
        end
      end

      context "config.ensure_role_set=false" do
        let(:ensure_role_set) { false }

        it "executes migrations" do
          migration = TestMigration.new

          expect(migration).to receive(:up)
          migration.exec_migration(conn, :up)
        end

      end
    end

  end
end
