require File.dirname(__FILE__) + '/../spec_helper'
require 'migration_test_helper'
include MigrationTestHelper
describe TestFluxSchemaObject do
  def test_the_schema
    adapter_name = ActiveRecord::Base.connection.adapter_name
#    assert_schema do |s|
      assert_table "FLUX_ACTION" do |t|
        t.column "pk",                :integer,                   :null => false
        t.column "clazz",             :string,  :limit => 200,  :null => false
        t.column "flow_chart",        :integer,                   :null => false
        t.column "name",              :string,  :limit => 200,  :null => false
        t.column "starting_point",    :integer,                   :null => false
        t.column "join_point",        :integer,                   :null => false
        t.column "transaction_break", :integer,                   :null => false
        t.column "timeout_timexp",    :string,  :limit => 200
        t.column "sub_flow_chart",    :integer
        t.column "pre_script_lang",   :string,  :limit => 200
        t.column "post_script_lang",  :string,  :limit => 200
        t.column "pre_script",        :text
        t.column "post_script",       :text
        t.column "skippable",         :integer,                   :null => false
        t.index :flow_chart, :name => "flux_action1"
      end

      assert_table "FLUX_AUDIT_TRAIL" do |t|
        t.column "pk",                :integer,                    :null => false
        t.column "engine",            :string,   :limit => 200,  :null => false
        t.column "username",          :string,   :limit => 200
        t.column "groupname",         :string,   :limit => 200
        t.column "namespace",         :string,   :limit => 200
        t.column "event",             :string,   :limit => 200
        t.column "transaction_id",    :string,   :limit => 200
        t.column "creation",          :datetime
        t.column "message",           :text
        t.column "action_name",       :string,   :limit => 200
        t.column "fk_run_history_pk", :integer
        t.index :creation, :name => "flux_audit_trail1"
        t.index :namespace, :name => "flux_audit_trail2"
        t.index :action_name, :name => "flux_audit_trail3"
        t.index :event, :name => "flux_audit_trail4"
        t.index :username, :name => "flux_audit_trail5"
        t.index :groupname, :name => "flux_audit_trail6"
        t.index :transaction_id, :name => "flux_audit_trail7"
      end

      assert_table "FLUX_BAG_ITEM" do |t|
        t.column "pk",               :integer,  :null => false
        t.column "bag_id",           :integer,  :null => false
        t.column "element_position", :integer
        t.index :bag_id, :name => "flux_bag_item1"
      end

      assert_table "FLUX_BIZ_PROCESS" do |t|
        t.column "pk",               :integer,    :null => false
        t.column "fk_flow_chart_pk", :integer,    :null => false
        t.column "template_name",    :string,   :limit => 200
        t.column "creation",         :datetime,                :null => false
        t.index :fk_flow_chart_pk, :name => "flux_biz_uniq_idx", :unique => true
      end

      assert_table "FLUX_BIZ_PROCESS_T" do |t|
        t.column "pk",           :integer,                   :null => false
        t.column "participant",  :string,  :limit => 200,  :null => false
        t.column "claimer",      :string,  :limit => 200
        t.column "wait_for_all", :integer,                   :null => false
        t.column "confirmed",    :integer,                   :null => false
      end

      assert_table "FLUX_BIZ_PROC_CONF" do |t|
        t.column "pk",                :integer,                   :null => false
        t.column "biz_process_t",     :integer,                   :null => false
        t.column "participant",       :string,  :limit => 200,  :null => false
        t.column "confirmation_type", :string,  :limit => 200
        t.column "ext_participant",   :integer,                   :null => false
      end

      assert_table "FLUX_BIZ_PROC_OWNR" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "fk_flow_chart_pk", :integer,                   :null => false
        t.column "name",             :string,  :limit => 200,  :null => false
      end

      assert_table "FLUX_CALLSTACK" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "fk_ready_caller_pk", :integer,  :null => false
        t.column "fk_ready_callee_pk", :integer,  :null => false
        t.column "is_primary",         :integer,  :null => false
      end

      assert_table "FLUX_CHKPT" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "flow",               :integer
        t.column "flow_chart",         :integer
        t.column "message_definition", :integer,  :null => false
        t.column "publisher",          :integer,  :null => false
        t.index :publisher, :name => "flux_chkpt1"
        t.index :flow_chart, :name => "flux_chkpt2"
        t.index :flow, :name => "flux_chkpt3"
      end

      assert_table "FLUX_CLUSTER" do |t|
        t.column "pk",              :integer,                   :null => false
        t.column "engine_instance", :integer,                   :null => false
        t.column "current_state",   :string,  :limit => 200,  :null => false
        t.column "heartbeat",       :integer,                   :null => false
        t.column "name",            :string,  :limit => 200,  :null => false
        t.column "host",            :string,  :limit => 200
        t.column "bind_name",       :string,  :limit => 200
        t.column "port",            :integer,                   :null => false
      end

      assert_table "FLUX_CLUSTER_NAME" do |t|
        t.column "id", :string, :limit => 200
        t.column "name", :string, :limit => 200
      end

      assert_table "FLUX_DATA_MAP" do |t|
        t.column "pk",          :integer,                   :null => false
        t.column "action",      :integer
        t.column "flow",        :integer
        t.column "source_name", :string,  :limit => 200,  :null => false
        t.column "source_type", :integer,                   :null => false
        t.column "target_name", :string,  :limit => 200,  :null => false
        t.column "target_type", :integer,                   :null => false
      end

      assert_table "FLUX_ERROR_RESULT" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "message",          :text
        t.column "clazz",            :string,  :limit => 200,  :null => false
        t.column "throwing_action",  :string,  :limit => 200,  :null => false
        t.column "stack_trace",      :text
        t.column "exception_object", :binary
      end


      assert_table "FLUX_FLOW_CHART" do |t|
        t.column "pk",                 :integer,                    :null => false
        t.column "name",               :string,   :limit => 200,  :null => false
        t.column "seal",               :integer,                    :null => false
        t.column "run_as_user",        :string,   :limit => 200
        t.column "listener_classpath", :string,   :limit => 200
        t.column "run_as_user_source", :integer,                    :null => false
        t.column "is_template",        :integer,                    :null => false
        t.column "deadline_ts",        :datetime
        t.column "deadline_timexp",    :string,   :limit => 200
        t.column "deadline_window",    :datetime
        t.column "deadline_window_te", :string,   :limit => 200
        t.column "deadline_status",    :integer
        t.index "name", :name => "flux_flow_chart_uniq_idx", :unique => true
        t.index :seal, :name => "flux_flow_chart1"

      end

      assert_table "FLUX_FLOW_CONTEXT" do |t|
        t.column "pk", :integer,  :null => false
      end

      assert_table "FLUX_GROUP" do |t|
        t.column "pk",         :integer,                  :null => false
        t.column "name",       :string,   :limit => 200,  :null => false
        t.column "expiration", :datetime
        t.index "name", :name => "flux_group_uniq_idx", :unique => true
      end

      assert_table "FLUX_JBIG_DECIMAL" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JBOOLEAN" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end
    assert_table "FLUX_FLOW" do |t|
        t.column "pk",            :integer,   :null => false
        t.column "target_action", :integer,   :null => false
        t.column "source_action", :integer,   :null => false
        col_name = adapter_name == "MySQL" ? "condizion" : "condition"
        t.column col_name,     :string,  :limit => 200
        t.index :source_action, :name => "flux_flow1"
        t.index :target_action, :name => "flux_flow2"
      end
      assert_table "FLUX_JBYTE_ARRAY" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :binary
      end

      assert_table "FLUX_JDATE" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      assert_table "FLUX_JDOUBLE" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JFLOAT" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JINTEGER" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JLONG" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JOINING" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "flow",  :integer,  :null => false
        t.column "ready", :integer,  :null => false
        t.column "queue", :integer,  :null => false
        t.column "fired", :integer,  :null => false
      end

      assert_table "FLUX_JSHORT" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      assert_table "FLUX_JSTRING" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :text
      end

      assert_table "FLUX_JTIME" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      assert_table "FLUX_JTIMESTAMP" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      assert_table "FLUX_LOCK" do |t|
        t.column "pk",                :integer,   :null => false
        t.column "fk_user_pk",        :integer,   :null => false
        t.column "fk_usr_rol_grp_pk", :integer,   :null => false
        t.column "type",              :integer,   :null => false
        t.column "creation",          :datetime,               :null => false
        t.index :fk_usr_rol_grp_pk, :name => "flux_lock_uniq_idx", :unique => true
        t.index :fk_user_pk, :name => "flux_lock1"
        t.index :creation, :name => "flux_lock3"
      end

      assert_table "FLUX_LOGGING" do |t|
        t.column "pk",            :integer,                    :null => false
        t.column "engine",        :string,   :limit => 200,  :null => false
        t.column "username",      :string,   :limit => 200
        t.column "groupname",     :string,   :limit => 200
        t.column "namespace",     :string,   :limit => 200
        t.column "logger_type",   :string,   :limit => 200
        t.column "logging_level", :string,   :limit => 200
        t.column "creation",      :datetime
        t.column "message",       :text
        t.index :creation, :name => "flux_logging1"
        t.index :namespace, :name => "flux_logging2"
        t.index :username, :name => "flux_logging3"
        t.index :groupname, :name => "flux_logging4"
        t.index :engine, :name => "flux_logging5"
        t.index :logger_type, :name => "flux_logging6"
        t.index :logging_level, :name => "flux_logging7"

      end

      assert_table "FLUX_MESSAGE_TGR" do |t|
        t.column "pk",              :integer,   :null => false
        t.column "publisher",       :integer,   :null => false
        t.column "last_message",    :integer
        t.column "current_message", :integer
        t.column "filter",          :string,  :limit => 200
        t.index :publisher, :name => "flux_message_tgr1"
        t.index :last_message, :name => "flux_message_tgr2"
        t.index :current_message, :name => "flux_message_tgr3"
      end

      assert_table "FLUX_META_BAG" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "bag_id",           :integer,                   :null => false
        t.column "bag_class",        :string,  :limit => 200,  :null => false
        t.column "comparator_class", :string,  :limit => 200
        t.index :bag_id, :name => "flux_meta_bag1"
      end

      assert_table "FLUX_MEZZAGE" do |t|
        t.column "pk",           :integer,  :null => false
        t.column "body",         :integer,  :null => false
        t.column "properties",   :integer,  :null => false
        t.column "publish_date", :integer,  :null => false
        t.column "publisher",    :integer,  :null => false
        t.column "priority",     :integer,  :null => false
        t.index :publisher, :name => "flux_mezzage1"
      end

      assert_table "FLUX_PERMISSION" do |t|
        t.column "pk",                 :integer,   :null => false
        t.column "fk_user_or_role_pk", :integer,   :null => false
        t.column "type",               :integer,   :null => false
        t.column "classname",          :string,  :limit => 200
        t.column "name",               :string,  :limit => 200
        t.column "actions",            :string,  :limit => 200
        t.column "variable_name",      :string,  :limit => 200
        t.column "variable_type",      :string,  :limit => 10
        t.column "action_name",        :string,  :limit => 200
      end

      assert_table "FLUX_PK" do |t|
        t.column "pk",      :integer,  :null => false
        t.column "next_pk", :integer,  :null => false
      end

      assert_table "FLUX_PUBLISHER" do |t|
        t.column "pk",                :integer,                   :null => false
        t.column "name",              :string,  :limit => 200,  :null => false
        t.column "style",             :string,  :limit => 200,  :null => false
        t.column "paused",            :string,  :limit => 200,  :null => false
        t.column "max_messages",      :integer,                   :null => false
        t.column "expiration_timexp", :string,  :limit => 200
        t.index :name, :name => "flux_publisher_uniq_idx", :unique => true
        t.index :style, :name => "flux_publisher1"
      end

      assert_table "FLUX_READY" do |t|
        t.column "pk",                 :integer,                    :null => false
        t.column "namespace",          :string,   :limit => 200,  :null => false
        t.column "flow_chart_name",    :string,   :limit => 200,  :null => false
        t.column "action",             :integer,                    :null => false
        t.column "expedited",          :integer,                    :null => false
        t.column "flow_context",       :integer,                    :null => false
        t.column "heartbeat",          :integer,                    :null => false
        t.column "instance",           :integer
        t.column "interrupted",        :integer
        t.column "seal",               :integer
        t.column "super_state",        :string,   :limit => 200,  :null => false
        t.column "state",              :string,   :limit => 200,  :null => false
        t.column "resume_action",      :integer
        t.column "resume_flow_cntxt",  :integer
        t.column "failed_error",       :integer
        t.column "execution_time",     :integer
        t.column "timeout",            :datetime
        t.column "original_priority",  :integer
        t.column "effective_priority", :integer
        t.column "last_prty_change",   :integer
        t.column "priority_source",    :integer,                    :null => false
        t.column "error_action",       :integer
        t.column "status",             :string,   :limit => 200
        t.index :action, :name => "flux_ready1"
        t.index :seal, :name => "flux_ready2"
        t.index :state, :name => "flux_ready3"
        t.index :heartbeat, :name => "flux_ready4"
        t.index :flow_chart_name, :name => "flux_ready5"
        t.index :execution_time, :name => "flux_ready6"
      end

      assert_table "FLUX_REPOSITORY" do |t|
        t.column "pk",            :integer,                    :null => false
        t.column "namespace",     :string,   :limit => 200,  :null => false
        t.column "content",       :text,                     :null => false
        t.column "description",   :text
        t.column "owner",         :integer
        t.column "creation",      :datetime,                                :null => false
        t.column "last_modified", :datetime,                                :null => false
        t.column "type",          :integer,                    :null => false
        t.index :namespace, :name => "flux_repository_uniq_idx", :unique => true
      end

      assert_table "FLUX_ROLE" do |t|
        t.column "pk",       :integer,                   :null => false
        t.column "name",     :string,  :limit => 200,  :null => false
        t.column "group_fk", :integer,                   :null => false
        t.index :name, :name => "flux_role1"
      end

      assert_table "FLUX_RUN_AVERAGE" do |t|
        t.column "namespace",         :string,   :limit => 200,  :null => false
        t.column "start_timestamp",   :integer,                    :null => false
        t.column "end_timestamp",     :integer,                    :null => false
        t.column "average_run_time",  :integer,                    :null => false
        t.column "average_wait_time", :integer,                    :null => false
        t.column "firing_count",      :integer,                    :null => false
        t.column "last_modified",     :datetime,                   :null => false
        t.index :namespace, :name => "flux_run_average_uniq_idx", :unique => true
        t.index :last_modified, :name => "flux_run_average1"
      end

      assert_table "FLUX_RUN_HISTORY" do |t|
        t.column "pk",              :integer,                    :null => false
        t.column "namespace",       :string,   :limit => 200,  :null => false
        t.column "action_name",     :string,   :limit => 200
        t.column "enter_timestamp", :integer,                    :null => false
        t.column "start_timestamp", :integer,                    :null => false
        t.column "exit_timestamp",  :integer,                    :null => false
        t.column "last_modified",   :datetime,                                :null => false
        t.column "success_status",  :integer,                    :null => false
        t.column "premature",       :integer,                    :null => false
        t.index :last_modified, :name => "flux_run_history1"
        t.index :namespace, :name => "flux_run_history2"
      end

      assert_table "FLUX_SIGNAL" do |t|
        t.column "pk",      :integer,                   :null => false
        t.column "monitor", :integer
        t.column "raise",   :integer
        t.column "clear",   :integer
        t.column "raised",  :integer
        t.column "name",    :string,  :limit => 200,  :null => false
      end

      assert_table "FLUX_TIMER_TRIGGER" do |t|
        t.column "pk",               :integer,   :null => false
        t.column "late_time_window", :string,  :limit => 200
        t.column "scheduled_t_date", :integer,   :null => false
        t.column "end_date",         :integer,   :null => false
        t.column "end_time_exp",     :string,  :limit => 200
        t.column "total_count",      :integer,   :null => false
        t.column "remaining_count",  :integer,   :null => false
        t.column "actual_t_date",    :integer,   :null => false
        t.column "abstract_timexp",  :integer
        t.column "makeup_firing",    :integer,   :null => false
      end

      assert_table "FLUX_USER" do |t|
        t.column "pk",           :integer,                   :null => false
        t.column "username",     :string,  :limit => 200,  :null => false
        t.column "password",     :string,  :limit => 200,  :null => false
        t.column "display_name", :string,  :limit => 200
        t.column "group_fk",     :integer,                   :null => false
        t.index :username, :name => "flux_user_uniq_idx", :unique => true
      end

      assert_table "FLUX_USER_ROLE_REL" do |t|
        t.column "pk",         :integer,  :null => false
        t.column "fk_user_pk", :integer,  :null => false
        t.column "fk_role_pk", :integer,  :null => false
        t.index :fk_user_pk, :name => "flux_usr_rol_relation1"
        t.index :fk_role_pk, :name => "flux_usr_rol_relation2"
      end

      assert_table "FLUX_USR_SUPR_REL" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "fk_user_pk",         :integer,  :null => false
        t.column "fk_role_pk",         :integer
        t.column "fk_user_or_role_pk", :integer,  :null => false
        t.column "type",               :integer,  :null => false
      end

      assert_table "FLUX_VARIABLE" do |t|
        t.column "pk",            :integer,                   :null => false
        t.column "owner",         :integer
        t.column "type",          :string,  :limit => 200,  :null => false
        t.column "name",          :string,  :limit => 200
        t.column "user_variable", :integer,                   :null => false
        t.index :owner, :name => "flux_variable1"
        t.index :user_variable, :name => "flux_variable2"
        t.index :name, :name => "flux_variable3"
      end
    end
#  end
end
  
