require File.dirname(__FILE__) + '/../spec_helper'
#require 'migration_test_helper'
#include MigrationTestHelper
describe TestApplicationSchemaObject do
  def test_the_schema
    adapter_name = ActiveRecord::Base.connection.adapter_name
    assert_schema do |s|
      ###############################
      # Tables used by flux engine###
      ###############################
      s.table "FLUX_ACTION" do |t|
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

      s.table "FLUX_AUDIT_TRAIL" do |t|
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

      s.table "FLUX_BAG_ITEM" do |t|
        t.column "pk",               :integer,  :null => false
        t.column "bag_id",           :integer,  :null => false
        t.column "element_position", :integer
        t.index :bag_id, :name => "flux_bag_item1"
      end

      s.table "FLUX_BIZ_PROCESS" do |t|
        t.column "pk",               :integer,    :null => false
        t.column "fk_flow_chart_pk", :integer,    :null => false
        t.column "template_name",    :string,   :limit => 200
        t.column "creation",         :datetime,                :null => false
        t.index :fk_flow_chart_pk, :name => "flux_biz_uniq_idx", :unique => true
      end

      s.table "FLUX_BIZ_PROCESS_T" do |t|
        t.column "pk",           :integer,                   :null => false
        t.column "participant",  :string,  :limit => 200,  :null => false
        t.column "claimer",      :string,  :limit => 200
        t.column "wait_for_all", :integer,                   :null => false
        t.column "confirmed",    :integer,                   :null => false
      end

      s.table "FLUX_BIZ_PROC_CONF" do |t|
        t.column "pk",                :integer,                   :null => false
        t.column "biz_process_t",     :integer,                   :null => false
        t.column "participant",       :string,  :limit => 200,  :null => false
        t.column "confirmation_type", :string,  :limit => 200
        t.column "ext_participant",   :integer,                   :null => false
      end

      s.table "FLUX_BIZ_PROC_OWNR" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "fk_flow_chart_pk", :integer,                   :null => false
        t.column "name",             :string,  :limit => 200,  :null => false
      end

      s.table "FLUX_CALLSTACK" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "fk_ready_caller_pk", :integer,  :null => false
        t.column "fk_ready_callee_pk", :integer,  :null => false
        t.column "is_primary",         :integer,  :null => false
      end

      s.table "FLUX_CHKPT" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "flow",               :integer
        t.column "flow_chart",         :integer
        t.column "message_definition", :integer,  :null => false
        t.column "publisher",          :integer,  :null => false
        t.index :publisher, :name => "flux_chkpt1"
        t.index :flow_chart, :name => "flux_chkpt2"
        t.index :flow, :name => "flux_chkpt3"
      end

      s.table "FLUX_CLUSTER" do |t|
        t.column "pk",              :integer,                   :null => false
        t.column "engine_instance", :integer,                   :null => false
        t.column "current_state",   :string,  :limit => 200,  :null => false
        t.column "heartbeat",       :integer,                   :null => false
        t.column "name",            :string,  :limit => 200,  :null => false
        t.column "host",            :string,  :limit => 200
        t.column "bind_name",       :string,  :limit => 200
        t.column "port",            :integer,                   :null => false
      end

      s.table "FLUX_CLUSTER_NAME" do |t|
        t.column "id", :string, :limit => 200
        t.column "name", :string, :limit => 200
      end

      s.table "FLUX_DATA_MAP" do |t|
        t.column "pk",          :integer,                   :null => false
        t.column "action",      :integer
        t.column "flow",        :integer
        t.column "source_name", :string,  :limit => 200,  :null => false
        t.column "source_type", :integer,                   :null => false
        t.column "target_name", :string,  :limit => 200,  :null => false
        t.column "target_type", :integer,                   :null => false
      end

      s.table "FLUX_ERROR_RESULT" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "message",          :text
        t.column "clazz",            :string,  :limit => 200,  :null => false
        t.column "throwing_action",  :string,  :limit => 200,  :null => false
        t.column "stack_trace",      :text
        t.column "exception_object", :binary
      end


      s.table "FLUX_FLOW_CHART" do |t|
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

      s.table "FLUX_FLOW_CONTEXT" do |t|
        t.column "pk", :integer,  :null => false
      end

      s.table "FLUX_GROUP" do |t|
        t.column "pk",         :integer,                  :null => false
        t.column "name",       :string,   :limit => 200,  :null => false
        t.column "expiration", :datetime
        t.index "name", :name => "flux_group_uniq_idx", :unique => true
      end

      s.table "FLUX_JBIG_DECIMAL" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JBOOLEAN" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end
      s.table "FLUX_FLOW" do |t|
        t.column "pk",            :integer,   :null => false
        t.column "target_action", :integer,   :null => false
        t.column "source_action", :integer,   :null => false
        col_name = adapter_name == "MySQL" ? "condizion" : "condition"
        t.column col_name,     :string,  :limit => 200
        t.index :source_action, :name => "flux_flow1"
        t.index :target_action, :name => "flux_flow2"
      end
      s.table "FLUX_JBYTE_ARRAY" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :binary
      end

      s.table "FLUX_JDATE" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      s.table "FLUX_JDOUBLE" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JFLOAT" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JINTEGER" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JLONG" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JOINING" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "flow",  :integer,  :null => false
        t.column "ready", :integer,  :null => false
        t.column "queue", :integer,  :null => false
        t.column "fired", :integer,  :null => false
      end

      s.table "FLUX_JSHORT" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :integer
      end

      s.table "FLUX_JSTRING" do |t|
        t.column "pk",    :integer,  :null => false
        t.column "value", :text
      end

      s.table "FLUX_JTIME" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      s.table "FLUX_JTIMESTAMP" do |t|
        t.column "pk",    :integer,   :null => false
        t.column "value", :datetime
      end

      s.table "FLUX_LOCK" do |t|
        t.column "pk",                :integer,   :null => false
        t.column "fk_user_pk",        :integer,   :null => false
        t.column "fk_usr_rol_grp_pk", :integer,   :null => false
        t.column "type",              :integer,   :null => false
        t.column "creation",          :datetime,               :null => false
        t.index :fk_usr_rol_grp_pk, :name => "flux_lock_uniq_idx", :unique => true
        t.index :fk_user_pk, :name => "flux_lock1"
        t.index :creation, :name => "flux_lock3"
      end

      s.table "FLUX_LOGGING" do |t|
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

      s.table "FLUX_MESSAGE_TGR" do |t|
        t.column "pk",              :integer,   :null => false
        t.column "publisher",       :integer,   :null => false
        t.column "last_message",    :integer
        t.column "current_message", :integer
        t.column "filter",          :string,  :limit => 200
        t.index :publisher, :name => "flux_message_tgr1"
        t.index :last_message, :name => "flux_message_tgr2"
        t.index :current_message, :name => "flux_message_tgr3"
      end

      s.table "FLUX_META_BAG" do |t|
        t.column "pk",               :integer,                   :null => false
        t.column "bag_id",           :integer,                   :null => false
        t.column "bag_class",        :string,  :limit => 200,  :null => false
        t.column "comparator_class", :string,  :limit => 200
        t.index :bag_id, :name => "flux_meta_bag1"
      end

      s.table "FLUX_MEZZAGE" do |t|
        t.column "pk",           :integer,  :null => false
        t.column "body",         :integer,  :null => false
        t.column "properties",   :integer,  :null => false
        t.column "publish_date", :integer,  :null => false
        t.column "publisher",    :integer,  :null => false
        t.column "priority",     :integer,  :null => false
        t.index :publisher, :name => "flux_mezzage1"
      end

      s.table "FLUX_PERMISSION" do |t|
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

      s.table "FLUX_PK" do |t|
        t.column "pk",      :integer,  :null => false
        t.column "next_pk", :integer,  :null => false
      end

      s.table "FLUX_PUBLISHER" do |t|
        t.column "pk",                :integer,                   :null => false
        t.column "name",              :string,  :limit => 200,  :null => false
        t.column "style",             :string,  :limit => 200,  :null => false
        t.column "paused",            :string,  :limit => 200,  :null => false
        t.column "max_messages",      :integer,                   :null => false
        t.column "expiration_timexp", :string,  :limit => 200
        t.index :name, :name => "flux_publisher_uniq_idx", :unique => true
        t.index :style, :name => "flux_publisher1"
      end

      s.table "FLUX_READY" do |t|
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

      s.table "FLUX_REPOSITORY" do |t|
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

      s.table "FLUX_ROLE" do |t|
        t.column "pk",       :integer,                   :null => false
        t.column "name",     :string,  :limit => 200,  :null => false
        t.column "group_fk", :integer,                   :null => false
        t.index :name, :name => "flux_role1"
      end

      s.table "FLUX_RUN_AVERAGE" do |t|
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

      s.table "FLUX_RUN_HISTORY" do |t|
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

      s.table "FLUX_SIGNAL" do |t|
        t.column "pk",      :integer,                   :null => false
        t.column "monitor", :integer
        t.column "raise",   :integer
        t.column "clear",   :integer
        t.column "raised",  :integer
        t.column "name",    :string,  :limit => 200,  :null => false
      end

      s.table "FLUX_TIMER_TRIGGER" do |t|
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

      s.table "FLUX_USER" do |t|
        t.column "pk",           :integer,                   :null => false
        t.column "username",     :string,  :limit => 200,  :null => false
        t.column "password",     :string,  :limit => 200,  :null => false
        t.column "display_name", :string,  :limit => 200
        t.column "group_fk",     :integer,                   :null => false
        t.index :username, :name => "flux_user_uniq_idx", :unique => true
      end

      s.table "FLUX_USER_ROLE_REL" do |t|
        t.column "pk",         :integer,  :null => false
        t.column "fk_user_pk", :integer,  :null => false
        t.column "fk_role_pk", :integer,  :null => false
        t.index :fk_user_pk, :name => "flux_usr_rol_relation1"
        t.index :fk_role_pk, :name => "flux_usr_rol_relation2"
      end

      s.table "FLUX_USR_SUPR_REL" do |t|
        t.column "pk",                 :integer,  :null => false
        t.column "fk_user_pk",         :integer,  :null => false
        t.column "fk_role_pk",         :integer
        t.column "fk_user_or_role_pk", :integer,  :null => false
        t.column "type",               :integer,  :null => false
      end

      s.table "FLUX_VARIABLE" do |t|
        t.column "pk",            :integer,                   :null => false
        t.column "owner",         :integer
        t.column "type",          :string,  :limit => 200,  :null => false
        t.column "name",          :string,  :limit => 200
        t.column "user_variable", :integer,                   :null => false
        t.index :owner, :name => "flux_variable1"
        t.index :user_variable, :name => "flux_variable2"
        t.index :name, :name => "flux_variable3"
      end

      ###############################
      # Tables used by application ##
      ###############################
      
      s.table "AccountActivityTypes" do |t|
        t.column "account_activity_type_id",   :string,  :limit => 25,                     :null => false
        t.column "account_activity_type_name", :string,  :limit => 35,                     :null => false
        t.column "description",                :string,  :limit => 50
        t.column "credit_debit_indicator",     :string,  :limit => 1,                      :null => false
        t.column "pfm_type",                   :string,  :limit => 15, :default => "NONE", :null => false
        t.column "lock_version",               :integer, :default => 0,      :null => false
      end

      s.table "AccountDisplaySetting" do |t|
        t.column "account_display_setting_id", :integer,                :null => false
        t.column "account_display_format",     :string,  :limit => 19,                :null => false
        t.column "amount_column_format",       :string,  :limit => 6,                 :null => false
        t.column "currency_symbol",            :string,  :limit => 15,                :null => false
        t.column "negative_amount_style",      :string,  :limit => 2,                 :null => false
        t.column "lock_version",               :integer, :default => 0, :null => false
      end

      s.table "AccountSetDetails" do |t|
        t.column "account_set_id", :integer,                 :null => false
        t.column "account_num",    :string,  :limit => 25,                :null => false
        t.column "lock_version",   :integer,  :default => 0, :null => false
      end

      s.table "AccountSets" do |t|
        t.column "account_set_id",   :integer,                 :null => false
        t.column "account_set_name", :string,  :limit => 35,                :null => false
        t.column "company_id",       :string,  :limit => 12,                :null => false
        t.column "currency_code",    :string,  :limit => 3,                 :null => false
        t.column "lock_version",     :integer,  :default => 0, :null => false
      end

      s.table "Addresses" do |t|
        t.column "address_id",    :integer,                  :null => false
        t.column "location_addr", :string,  :limit => 109,                :null => false
        t.column "city_name",     :string,  :limit => 35,                 :null => false
        t.column "state_name",    :string,  :limit => 35
        t.column "postal_code",   :string,  :limit => 15,                 :null => false
        t.column "country_code",  :string,  :limit => 2
        t.column "lock_version",  :integer,   :default => 0, :null => false
      end

      s.table "AdvancedSignatureParams" do |t|
        t.column "advanced_signature_param_id",    :integer,                 :null => false
        t.column "signature_parameter_id",         :integer,                 :null => false
        t.column "signature_group_combination_id", :integer,                 :null => false
        t.column "threshold_amt",                  :integer,                 :null => false
        t.column "lock_version",                   :integer,  :default => 0, :null => false
        t.index [:signature_parameter_id, :signature_group_combination_id], :name => :adv_sp_1, :unique => true
      end

      s.table "AlertConfigurations" do |t|
        t.column "alert_id",                    :string,  :limit => 25,                 :null => false
        t.column "alert_subject",               :string,  :limit => 50,                 :null => false
        t.column "alert_message",               :string,  :limit => 200,                :null => false
        t.column "alert_status",                :string,  :limit => 1,                  :null => false
        t.column "confirm_destination_address", :boolean,                               :null => false
        t.column "alert_interval_in_mins",      :integer,                  :null => false
        t.column "lock_version",                :integer,   :default => 0, :null => false
      end

      s.table "AlertDeviceConfigurations" do |t|
        t.column "alert_device_id", :string,  :limit => 12,                :null => false
        t.column "alert_id",        :string,  :limit => 25,                :null => false
        t.column "lock_version",    :integer,  :default => 0, :null => false
      end

      s.table "AlertDevices" do |t|
        t.column "alert_device_id",     :string,  :limit => 12,                :null => false
        t.column "description",         :string,  :limit => 50,                :null => false
        t.column "alert_device_status", :string,  :limit => 1,                 :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "Alerts" do |t|
        t.column "alert_id",     :string,  :limit => 25,                :null => false
        t.column "description",  :string,  :limit => 50,                :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "AppSecurityParameters" do |t|
        t.column "owner_id",                 :string,  :limit => 12,                :null => false
        t.column "ssl_key_size",             :integer,                 :null => false
        t.column "sti_type",                 :string,                               :null => false
        t.column "session_time_out_in_mins", :integer,                 :null => false
        t.column "lock_version",             :integer,  :default => 0, :null => false
      end

      s.table "AppUserReportUserMaps" do |t|
        t.column "report_user_id", :integer,  :null => false
        t.column "user_id",        :string,  :limit => 50, :null => false
        t.column "user_type",      :string,  :limit => 1,  :null => false
        t.column "company_id",     :string,  :limit => 12
        t.index [:user_id, :company_id], :name => :app_user_rep_maps_uniq_idx_1, :unique => true
      end

      s.table "AuditLogs" do |t|
        t.column "event_id",            :string,   :limit => 50,                :null => false
        t.column "event_date_time",     :datetime,                              :null => false
        t.column "event_micro_sec",     :integer,                  :null => false
        t.column "user_id",             :string,   :limit => 50,                :null => false
        t.column "transaction_ref",     :string,   :limit => 18
        t.column "transaction_type_id", :string,   :limit => 12
        t.column "company_id",          :string,   :limit => 12
        t.column "narrative",           :string
        t.column "lock_version",        :integer,   :default => 0, :null => false
        t.index [:event_date_time, :user_id, :transaction_type_id, :company_id], :name => :audit_log_1_idx
        t.index :transaction_ref, :name => :audit_log_2_idx
      end

      s.table "BasicSignatureParameters" do |t|
        t.column "signature_parameter_id",         :integer,                 :null => false
        t.column "fixed_signature",                :boolean,                              :null => false
        t.column "signature_tally",                :integer 
        t.column "one_signature_threshold_amt",    :integer 
        t.column "two_signatures_threshold_amt",   :integer 
        t.column "three_signatures_threshold_amt", :integer 
        t.column "lock_version",                   :integer,  :default => 0, :null => false
      end

      s.table "BatchTemplates" do |t|
        t.column "template_id",                   :integer,                    :null => false
        t.column "template_name",                 :string,   :limit => 25,                  :null => false
        t.column "description",                   :string,   :limit => 50
        t.column "offset_account_num",            :string,   :limit => 25,                  :null => false
        t.column "batch_item_tally",              :integer,                    :null => false
        t.column "template_status",               :string,   :limit => 35,                  :null => false
        t.column "remarks",                       :string
        t.column "transaction_type_id",           :string,   :limit => 12,                  :null => false
        t.column "transaction_code",              :string,   :limit => 25,                  :null => false
        t.column "company_id",                    :string,   :limit => 12,                  :null => false
        t.column "last_initiated_date_time",      :datetime
        t.column "input_file_content_id",         :integer  
        t.column "last_updated_by_id",            :string,   :limit => 50,                  :null => false
        t.column "last_updated_date_time",        :datetime,                                :null => false
        t.column "charges_borne_by",              :string,   :limit => 1
        t.column "instrument_template_id",        :string,   :limit => 3
        t.column "print_signature_on_instrument", :string,   :limit => 1
        t.column "one_time_batch",                :string,   :limit => 1,  :default => "0", :null => false
        t.column "lock_version",                  :integer,   :default => 0,   :null => false
        t.column "batch_amt",                     :integer,                    :null => false
        t.index [:company_id, :offset_account_num], :name => :batch_templates_1_idx, :unique => false
        t.index [:company_id, :template_name], :name => :batch_templates_uniq_idx_2, :unique => true
      end

      s.table "Batches" do |t|
        t.column "system_ref",                    :string,   :limit => 18,                   :null => false
        t.column "financial_institution_ref",     :string,   :limit => 18
        t.column "internal_description",          :string,   :limit => 100
        t.column "external_description",          :string,   :limit => 100
        t.column "batch_item_tally",              :integer,                     :null => false
        t.column "credit_tally",                  :integer,                     :null => false
        t.column "debit_tally",                   :integer,                     :null => false
        t.column "effective_date",                :date,                                     :null => false
        t.column "priority",                      :string
        t.column "batch_status",                  :string,   :limit => 35,                   :null => false
        t.column "remarks",                       :string
        t.column "scheduled_by_id",               :string,   :limit => 50
        t.column "scheduled_date_time",           :datetime,                                 :null => false
        t.column "transaction_type_id",           :string,   :limit => 12,                   :null => false
        t.column "company_id",                    :string,   :limit => 12,                   :null => false
        t.column "template_id",                   :integer  
        t.column "processed_date_time",           :datetime
        t.column "company_ref",                   :string,   :limit => 50
        t.column "file_content_id",               :integer  
        t.column "transaction_code",              :string,   :limit => 1,                    :null => false
        t.column "output_file_content_id",        :integer  
        t.column "other_party_ref",               :string,   :limit => 18
        t.column "charges_borne_by",              :string,   :limit => 1
        t.column "paper_instrument_pickup_date",  :date
        t.column "instrument_template_id",        :string,   :limit => 3
        t.column "update_to_client",              :string,   :limit => 1,   :default => "0", :null => false
        t.column "print_signature_on_instrument", :string,   :limit => 1
        t.column "lock_version",                  :integer,    :default => 0,   :null => false
        t.column "batch_amt",                     :integer,                     :null => false
        t.index [:company_id, :scheduled_by_id, :processed_date_time], :name => :batches_1_idx
      end

      s.table "BusinessAcActivityDetails" do |t|
        t.column "account_activity_detail_id", :integer,                  :null => false
        t.column "account_num",                :string,  :limit => 25,                 :null => false
        t.column "account_activity_date",      :date,                                  :null => false
        t.column "description",                :string,  :limit => 200
        t.column "transaction_amt",            :integer,                  :null => false
        t.column "credit_debit_indicator",     :string,  :limit => 1
        t.column "account_activity_type_id",   :string,  :limit => 25,                 :null => false
        t.column "cheque_num",                 :integer
        t.column "lock_version",               :integer,   :default => 0, :null => false
        t.index [:account_num, :account_activity_date], :name => :bus_ac_activity_details_1_idx
        t.index [:credit_debit_indicator, :transaction_amt], :name => :bus_ac_activity_details_2_idx
      end

      s.table "BusinessAccountActivities" do |t|
        t.column "account_num",           :string,  :limit => 25,                :null => false
        t.column "account_activity_date", :date,                                 :null => false
        t.column "custom_field_1",        :string,  :limit => 50
        t.column "custom_field_2",        :string,  :limit => 50
        t.column "custom_field_3",        :string,  :limit => 50
        t.column "custom_field_4",        :string,  :limit => 50
        t.column "custom_balance_1_amt",  :integer
        t.column "custom_balance_2_amt",  :integer
        t.column "custom_balance_3_amt",  :integer
        t.column "custom_balance_4_amt",  :integer
        t.column "custom_balance_5_amt",  :integer
        t.column "custom_balance_6_amt",  :integer
        t.column "custom_balance_7_amt",  :integer
        t.column "custom_balance_8_amt",  :integer
        t.column "lock_version",          :integer,  :default => 0, :null => false
      end

      s.table "BusinessAccounts" do |t|
        t.column "account_num",                    :string,  :limit => 25,                    :null => false
        t.column "currency_code",                  :string,  :limit => 3,                     :null => false
        t.column "product_id",                     :string,                      :null => false
        t.column "transfer_from_opt",              :boolean,               :default => false, :null => false
        t.column "transfer_to_opt",                :boolean,               :default => false, :null => false
        t.column "bill_payment_opt",               :boolean,               :default => false, :null => false
        t.column "stop_payment_opt",               :boolean,               :default => false, :null => false
        t.column "other_payment_opt",              :boolean,               :default => false, :null => false
        t.column "tax_payment_opt",                :boolean,               :default => false, :null => false
        t.column "multi_currency_transaction_opt", :boolean,               :default => false, :null => false
        t.column "batch_opt",                      :boolean,               :default => false, :null => false
        t.column "product_sub_type_id",            :string,                      :null => false
        t.column "lock_version",                   :integer,  :default => 0,     :null => false
        t.index :product_id, :name => :business_accounts_1_idx
      end

      s.table "BusinessAssociations" do |t|
        t.column "company_id",        :string,  :limit => 12,                  :null => false
        t.column "account_num",       :string,  :limit => 25,                  :null => false
        t.column "account_nick_name", :string,  :limit => 35
        t.column "relationship_type", :string,  :limit => 1,  :default => "O", :null => false
        t.column "daily_limit_amt",   :integer
        t.column "access_level",      :string,  :limit => 1,                   :null => false
        t.column "lock_version",      :integer,  :default => 0,   :null => false
        t.index :relationship_type, :name => :bus_associations_1_idx
      end

      s.table "BusinessClassReports" do |t|
        t.column "class_id",      :string,  :limit => 12,                :null => false
        t.column "report_id",     :integer,                 :null => false
        t.column "report_status", :string,  :limit => 1
        t.column "lock_version",  :integer,  :default => 0, :null => false
        t.index :report_id, :name => :bus_class_rep_fk_1
      end

      s.table "BusinessClassUserProfiles" do |t|
        t.column "class_id",             :string,  :limit => 12,                :null => false
        t.column "user_profile_id",      :string,  :limit => 65,                :null => false
        t.column "temp_scaffold_column", :string,  :limit => 1
        t.column "lock_version",         :integer,  :default => 0, :null => false
      end

      s.table "BusinessClasses" do |t|
        t.column "class_id",                      :string,  :limit => 12,                :null => false
        t.column "sti_type",                      :string,  :limit => 70,                :null => false
        t.column "class_name",                    :string,  :limit => 25,                :null => false
        t.column "parent_class_id",               :string,  :limit => 12
        t.column "user_can_sign_own_transaction", :integer
        t.column "transaction_limit_amt",         :integer
        t.column "any_account_daily_limit_amt",   :integer
        t.column "daily_limit_amt",               :integer
        t.column "direct_pipe_opt",               :integer
        t.column "user_administration",           :string,  :limit => 25
        t.column "lock_version",                  :integer,  :default => 0, :null => false
        t.column "restrictive_payment_template",  :string,  :limit => 1
        t.index :user_can_sign_own_transaction, :name => :busines_classes_1_idx
      end

      s.table "BusinessFields" do |t|
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "field_name",          :string,  :limit => 30,                :null => false
        t.column "field_type",          :string,                  :null => false
        t.column "field_length",        :integer
        t.column "field_format",        :string,  :limit => 50
        t.column "field_constraint",    :string
        t.column "field_mandatory",     :boolean,                              :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "CPCDetails" do |t|
        t.column "system_ref",                :string,  :limit => 18,                   :null => false
        t.column "item_ref",                  :string,  :limit => 50,                   :null => false
        t.column "internal_ref",              :string,  :limit => 35
        t.column "account_num",               :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1",  :string,  :limit => 50
        t.column "bank_branch_identifier_2",  :string,  :limit => 50
        t.column "bank_branch_identifier_3",  :string,  :limit => 50
        t.column "transaction_amt",           :integer,                    :null => false
        t.column "transaction_status",        :string,  :limit => 35,                   :null => false
        t.column "company_name",              :string,  :limit => 50,                   :null => false
        t.column "remarks",                   :string
        t.column "transaction_code",          :string,  :limit => 1,                    :null => false
        t.column "external_ref",              :string,  :limit => 35
        t.column "advice_mode",               :string,  :limit => 2,                    :null => false
        t.column "payment_details",           :string,  :limit => 250
        t.column "financial_institution_ref", :string,  :limit => 18
        t.column "advice_communication_info", :string,  :limit => 200
        t.column "update_to_client",          :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",              :integer,   :default => 0,   :null => false
      end

      s.table "CPCTemplateDetails" do |t|
        t.column "item_id",                   :integer,                    :null => false
        t.column "internal_ref",              :string,  :limit => 35
        t.column "account_num",               :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1",  :string,  :limit => 50
        t.column "bank_branch_identifier_2",  :string,  :limit => 50
        t.column "bank_branch_identifier_3",  :string,  :limit => 50
        t.column "transaction_amt",           :integer,                    :null => false
        t.column "company_name",              :string,  :limit => 50,                   :null => false
        t.column "hold_effective_date",       :date
        t.column "external_ref",              :string,  :limit => 35
        t.column "advice_mode",               :string,  :limit => 2,                    :null => false
        t.column "payment_details",           :string,  :limit => 250
        t.column "advice_communication_info", :string,  :limit => 200
        t.column "one_time_item",             :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",              :integer,   :default => 0,   :null => false
        t.column "template_id",               :integer,                    :null => false
        t.column "hold_type",                 :string,  :limit => 1
      end

      s.table "CTEDetails" do |t|
        t.column "system_ref",                :string,  :limit => 18,                   :null => false
        t.column "item_ref",                  :string,  :limit => 50,                   :null => false
        t.column "internal_ref",              :string,  :limit => 35
        t.column "account_num",               :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1",  :string,  :limit => 50
        t.column "bank_branch_identifier_2",  :string,  :limit => 50
        t.column "bank_branch_identifier_3",  :string,  :limit => 50
        t.column "transaction_amt",           :integer,                    :null => false
        t.column "transaction_status",        :string,  :limit => 35,                   :null => false
        t.column "company_name",              :string,  :limit => 50,                   :null => false
        t.column "remarks",                   :string
        t.column "transaction_code",          :string,  :limit => 1,                    :null => false
        t.column "external_ref",              :string,  :limit => 35
        t.column "advice_mode",               :string,  :limit => 2,                    :null => false
        t.column "advice_communication_info", :string,  :limit => 200
        t.column "financial_institution_ref", :string,  :limit => 18
        t.column "tax_id",                    :string,  :limit => 10
        t.column "instrument_sign_set_id",    :string,  :limit => 3
        t.column "documents_for_pickup",      :string,  :limit => 24
        t.column "item_id",                   :integer
        t.column "update_to_client",          :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",              :integer,   :default => 0,   :null => false
      end

      s.table "CTETemplateDetails" do |t|
        t.column "item_id",                   :integer,                    :null => false
        t.column "internal_ref",              :string,  :limit => 35
        t.column "account_num",               :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1",  :string,  :limit => 50
        t.column "bank_branch_identifier_2",  :string,  :limit => 50
        t.column "bank_branch_identifier_3",  :string,  :limit => 50
        t.column "transaction_amt",           :integer,                    :null => false
        t.column "company_name",              :string,  :limit => 50,                   :null => false
        t.column "hold_effective_date",       :date
        t.column "external_ref",              :string,  :limit => 35
        t.column "advice_mode",               :string,  :limit => 2,                    :null => false
        t.column "advice_communication_info", :string,  :limit => 200
        t.column "tax_id",                    :string,  :limit => 10
        t.column "instrument_sign_set_id",    :string,  :limit => 3
        t.column "documents_for_pickup",      :string,  :limit => 24
        t.column "one_time_item",             :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",              :integer,   :default => 0,   :null => false
        t.column "template_id",               :integer,                    :null => false
        t.column "hold_type",                 :string,  :limit => 1
      end

      s.table "CompAcctTxnTypeUtilLimits" do |t|
        t.column "company_id",          :string,  :limit => 12,                :null => false
        t.column "account_num",         :string,  :limit => 25,                :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "as_on_date",          :date,                                 :null => false
        t.column "utilized_amt",        :integer,  :default => 0, :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "CompTxnTypeUtilLimits" do |t|
        t.column "company_id",          :string,  :limit => 12,                :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "as_on_date",          :date,                                 :null => false
        t.column "utilized_amt",        :integer,  :default => 0, :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "Companies" do |t|
        t.column "company_id",                     :string,  :limit => 12,                 :null => false
        t.column "company_name",                   :string,  :limit => 50,                 :null => false
        t.column "class_id",                       :string,  :limit => 12,                 :null => false
        t.column "address_id",                     :integer,                  :null => false
        t.column "company_status",                 :string,  :limit => 1,                  :null => false
        t.column "fi_representative_name",         :string,  :limit => 150
        t.column "fi_representative_manager_name", :string,  :limit => 150
        t.column "lock_version",                   :integer,   :default => 0, :null => false
      end

      s.table "CompanyAccountUtilLimits" do |t|
        t.column "company_id",   :string,  :limit => 12,                :null => false
        t.column "account_num",  :string,  :limit => 25,                :null => false
        t.column "as_on_date",   :date,                                 :null => false
        t.column "utilized_amt", :integer,  :default => 0, :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "CompanyAcctTxnTypeLimits" do |t|
        t.column "company_id",          :string,  :limit => 12,                :null => false
        t.column "account_num",         :string,  :limit => 25,                :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "daily_limit_amt",     :integer,                 :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "CompanyCertificates" do |t|
        t.column "certificate_id",    :integer,                  :null => false
        t.column "company_id",        :string,   :limit => 12,                :null => false
        t.column "file_content_id",   :integer,                  :null => false
        t.column "created_date_time", :datetime,                              :null => false
        t.column "lock_version",      :integer,   :default => 0, :null => false
        t.index :company_id, :name => :company_certificates_1_idx
      end

      s.table "CompanyPreferences" do |t|
        t.column "company_id",    :string,  :limit => 12,                :null => false
        t.column "currency_code", :string,  :limit => 3,                 :null => false
        t.column "lock_version",  :integer,  :default => 0, :null => false
      end

      s.table "CompanyUserUtilLimits" do |t|
        t.column "company_id",            :string,  :limit => 12,                :null => false
        t.column "user_id",               :string,  :limit => 50,                :null => false
        t.column "service_permission_id", :string,  :limit => 35,                :null => false
        t.column "service_id",            :string,  :limit => 18,                :null => false
        t.column "as_on_date",            :date,                                 :null => false
        t.column "util_daily_limit_amt",  :integer,                 :null => false
        t.column "lock_version",          :integer,  :default => 0, :null => false
      end

      s.table "CompanyUsers" do |t|
        t.column "user_id",            :string,  :limit => 50,                :null => false
        t.column "company_id",         :string,  :limit => 12,                :null => false
        t.column "signature_group_id", :string,  :limit => 12
        t.column "user_profile_id",    :string,  :limit => 65
        t.column "user_status",        :string,  :limit => 1,                 :null => false
        t.column "remarks",            :string
        t.column "lock_version",       :integer,  :default => 0, :null => false
      end

      s.table "CompanyUtilLimits" do |t|
        t.column "company_id",   :string,  :limit => 12,                :null => false
        t.column "as_on_date",   :date,                                 :null => false
        t.column "utilized_amt", :integer,  :default => 0, :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "CompanyWorkflowPreferences" do |t|
        t.column "company_id",          :string,  :limit => 12,                :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "verification_req",    :integer
        t.column "release_req",         :integer
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "Countries" do |t|
        t.column "country_code", :string,  :limit => 2,                 :null => false
        t.column "country_name", :string,  :limit => 50,                :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "CreditNoteTemplates" do |t|
        t.column "item_id",         :integer,                 :null => false
        t.column "credit_note_id",  :string,                  :null => false
        t.column "credit_note_amt", :integer,                 :null => false
        t.column "remarks",         :string
        t.column "tax_amt",         :integer
        t.column "lock_version",    :integer,  :default => 0, :null => false
        t.column "template_id",     :integer,                 :null => false
      end

      s.table "CreditNotes" do |t|
        t.column "system_ref",      :string,  :limit => 18,                :null => false
        t.column "item_ref",        :string,  :limit => 50,                :null => false
        t.column "credit_note_id",  :string,                  :null => false
        t.column "credit_note_amt", :integer,                 :null => false
        t.column "remarks",         :string
        t.column "tax_amt",         :integer
        t.column "lock_version",    :integer,  :default => 0, :null => false
      end

      s.table "Currencies" do |t|
        t.column "currency_code",   :string,  :limit => 3,                     :null => false
        t.column "description",     :string,  :limit => 100,                   :null => false
        t.column "scale",           :integer
        t.column "active",          :boolean,                :default => true, :null => false
        t.column "currency_symbol", :string,  :limit => 4
        t.column "lock_version",    :integer,   :default => 0,    :null => false
      end

      s.table "DirectPipeUploadedFiles" do |t|
        t.column "company_id",          :string,   :limit => 12,                :null => false
        t.column "company_ref",         :string,   :limit => 50,                :null => false
        t.column "file_content_id",     :integer,                  :null => false
        t.column "system_ref",          :string,   :limit => 18
        t.column "file_status",         :string,   :limit => 35,                :null => false
        t.column "remarks",             :string
        t.column "transaction_type_id", :string,   :limit => 12,                :null => false
        t.column "transaction_code",    :string,   :limit => 1,                 :null => false
        t.column "received_date_time",  :datetime,                              :null => false
        t.column "processed_date_time", :datetime
        t.column "lock_version",        :integer,   :default => 0, :null => false
      end

      s.table "DomesticBankBranchIdLabel" do |t|
        t.column "label_id",           :integer,                 :null => false
        t.column "identifier_1_label", :string,  :limit => 25,                :null => false
        t.column "identifier_2_label", :string,  :limit => 25
        t.column "identifier_3_label", :string,  :limit => 25
        t.column "lock_version",       :integer,  :default => 0, :null => false
      end

      s.table "DomesticBankBranches" do |t|
        t.column "bank_internal_id",    :integer,                 :null => false
        t.column "bank_name",           :string,  :limit => 70,                :null => false
        t.column "branch_name",         :string,  :limit => 70,                :null => false
        t.column "address_id",          :integer,                 :null => false
        t.column "branch_identifier_1", :string,  :limit => 50,                :null => false
        t.column "branch_identifier_2", :string,  :limit => 50
        t.column "branch_identifier_3", :string,  :limit => 50
        t.column "lock_version",        :integer,  :default => 0, :null => false
        t.index [:bank_name, :branch_name], :name => "dombkbranch_uniq_1", :unique => true
        t.index [:branch_identifier_1, :branch_identifier_2, :branch_identifier_3], :name => :dombkbranch_uniq_2, :unique => true
      end

      s.table "ElectronicPayments" do |t|
        t.column "system_ref",                :string,   :limit => 18,                   :null => false
        t.column "sti_type",                  :string,                                   :null => false
        t.column "debit_account_num",         :string,   :limit => 25,                   :null => false
        t.column "value_date",                :date,                                     :null => false
        t.column "internal_ref",              :string,   :limit => 35
        t.column "reference_for_payee",       :string,   :limit => 35
        t.column "advice_fax",                :integer
        t.column "advice_address_id",         :integer
        t.column "advice_to_payee",           :string,   :limit => 146
        t.column "charges_borne_by",          :string,   :limit => 1,   :default => "N", :null => false
        t.column "financial_institution_ref", :string,   :limit => 18
        t.column "scheduled_by_id",           :string,   :limit => 50,                   :null => false
        t.column "scheduled_date_time",       :datetime,                                 :null => false
        t.column "transaction_status",        :string,   :limit => 35,                   :null => false
        t.column "template_version",          :integer
        t.column "company_id",                :string,   :limit => 12,                   :null => false
        t.column "payment_currency_code",     :string,   :limit => 3
        t.column "payment_details",           :string,   :limit => 220
        t.column "intermediary_bank_id",      :integer
        t.column "transaction_amt",           :integer,                     :null => false
        t.column "advice_email",              :string,   :limit => 100
        t.column "lock_version",              :integer,    :default => 0,   :null => false
        t.column "payee_id",                  :integer,                     :null => false
        t.column "template_id",               :string,   :limit => 18
        t.column "advice_mode",               :string,   :limit => 2,                    :null => false
        t.index [:company_id, :scheduled_by_id, :debit_account_num], :name => :electronic_payments_1_idx
      end

      s.table "Events" do |t|
        t.column "event_id",     :string,  :limit => 50,                :null => false
        t.column "description",  :string,  :limit => 50,                :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "ExchangeRates" do |t|
        t.column "from_currency_code", :string,  :limit => 3,                                                :null => false
        t.column "to_currency_code",   :string,  :limit => 3,                                                :null => false
        t.column "exchange_rate",      :decimal,               :precision => 10, :scale => 6,                :null => false
        t.column "lock_version",       :integer,                                 :default => 0, :null => false
      end

      s.table "Exclusions" do |t|
        t.column "fixed_date",          :date,                                 :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "FIBranches" do |t|
        t.column "branch_id",    :string,  :limit => 12,                :null => false
        t.column "branch_name",  :string,  :limit => 50,                :null => false
        t.column "address_id",   :integer,                 :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "FXContracts" do |t|
        t.column "contract_ref", :string,  :limit => 50,                :null => false
        t.column "company_id",   :string,  :limit => 12
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "FileContents" do |t|
        t.column "file_content_id", :integer,                 :null => false
        t.column "file_name",       :string,                               :null => false
        t.column "checksum",        :string
        t.column "file_data",       :binary,                               :null => false
        t.column "lock_version",    :integer,  :default => 0, :null => false
      end

      s.table "FinancialInstitution" do |t|
        t.column "institution_id",   :string,  :limit => 12,                :null => false
        t.column "institution_name", :string,  :limit => 50,                :null => false
        t.column "currency_code",    :string,  :limit => 3,                 :null => false
        t.column "bank_internal_id", :integer
        t.column "address_id",       :integer,                 :null => false
        t.column "payee_activation_req", :string, :limit => 1, :default => '1', :null => false
        t.column "weekend_one",      :integer,                 :null => false
        t.column "weekend_two",      :integer,                 :null => false
        t.column "allow_adhoc_payee",:string, :limit => 1, :default => '0', :null => false
        t.column "lock_version",     :integer,  :default => 0, :null => false
      end

      s.table "HolidayExclusions" do |t|
        t.column "fixed_date",          :date,                                 :null => false
        t.column "transaction_type_id", :string,  :limit => 12,                :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "Holidays" do |t|
        t.column "holiday_name",      :string,  :limit => 50,                :null => false
        t.column "fixed_day",         :boolean,                              :null => false
        t.column "fixed_date",        :date
        t.column "holiday_month",     :integer
        t.column "day_of_the_week",   :integer
        t.column "day_of_the_month",  :integer
        t.column "week_of_the_month", :string,  :limit => 6
        t.column "lock_version",      :integer,  :default => 0, :null => false
      end

      s.table "IPCDetails" do |t|
        t.column "system_ref",                :string,  :limit => 18,                   :null => false
        t.column "item_ref",                  :string,  :limit => 50,                   :null => false
        t.column "internal_ref",              :string,  :limit => 35
        t.column "account_num",               :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1",  :string,  :limit => 50
        t.column "bank_branch_identifier_2",  :string,  :limit => 50
        t.column "bank_branch_identifier_3",  :string,  :limit => 50
        t.column "transaction_amt",           :integer,                    :null => false
        t.column "transaction_status",        :string,  :limit => 35,                   :null => false
        t.column "individual_name",           :string,  :limit => 150,                  :null => false
        t.column "financial_institution_ref", :string,  :limit => 18
        t.column "remarks",                   :string
        t.column "transaction_code",          :string,  :limit => 1,                    :null => false
        t.column "external_ref",              :string,  :limit => 35
        t.column "update_to_client",          :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",              :integer,   :default => 0,   :null => false
        t.index :account_num, :name => :ipc_details_1_idx
      end

      s.table "IPCTemplateDetails" do |t|
        t.column "item_id",                  :integer,                    :null => false
        t.column "account_num",              :string,  :limit => 25,                   :null => false
        t.column "bank_branch_identifier_1", :string,  :limit => 50
        t.column "bank_branch_identifier_2", :string,  :limit => 50
        t.column "bank_branch_identifier_3", :string,  :limit => 50
        t.column "transaction_amt",          :integer,                    :null => false
        t.column "individual_name",          :string,  :limit => 150,                  :null => false
        t.column "hold_effective_date",      :date
        t.column "internal_ref",             :string,  :limit => 35
        t.column "external_ref",             :string,  :limit => 35
        t.column "one_time_item",            :string,  :limit => 1,   :default => "0", :null => false
        t.column "lock_version",             :integer,   :default => 0,   :null => false
        t.column "template_id",              :integer,                    :null => false
        t.column "hold_type",                :string,  :limit => 1
        t.index :account_num, :name => :ipc_template_details_1_idx
      end

      s.table "InComingSecureMails" do |t|
        t.column "in_comming_mail_id",      :integer,                  :null => false
        t.column "company_id",              :string,   :limit => 12,                :null => false
        t.column "secure_message_group_id", :string,   :limit => 12,                :null => false
        t.column "message_subject",         :string,   :limit => 50,                :null => false
        t.column "message_body",            :text,                                  :null => false
        t.column "received_date_time",      :datetime,                              :null => false
        t.column "staff_id",                :string,   :limit => 50,                :null => false
        t.column "user_id",                 :string,   :limit => 50,                :null => false
        t.column "mark_as_read",            :boolean,                               :null => false
        t.column "mail_status",             :string,   :limit => 1,                 :null => false
        t.column "lock_version",            :integer,   :default => 0, :null => false
        t.index [:company_id, :staff_id, :user_id], :name => :incoming_secure_mails_1_idx
      end

      s.table "InternationalBanks" do |t|
        t.column "bank_internal_id",       :integer,                      :null => false
        t.column "sti_type",               :string,                                    :null => false
        t.column "bank_name",              :string,   :limit => 70,                    :null => false
        t.column "address_id",             :integer,                      :null => false
        t.column "system_added",           :boolean,                :default => false, :null => false
        t.column "owner_id",               :string,   :limit => 12,                    :null => false
        t.column "last_updated_by_id",     :string,   :limit => 50
        t.column "last_updated_date_time", :datetime
        t.column "lock_version",           :integer,   :default => 0,     :null => false
        t.index [:bank_name, :owner_id], :name => :internationalbanks_uniq_idx_1, :unique => true
      end

      s.table "IntlBankIdentifiers" do |t|
        t.column "bank_internal_id",     :integer,                 :null => false
        t.column "bank_identifier_type", :string,  :limit => 10,                :null => false
        t.column "bank_identifier",      :string,  :limit => 16,                :null => false
        t.column "bank_identifier_seq",  :integer,                 :null => false
        t.column "lock_version",         :integer,  :default => 0, :null => false
      end

      s.table "InvoiceAdjustmentTemplates" do |t|
        t.column "item_id",         :integer,                 :null => false
        t.column "document_id",     :string,  :limit => 20,                :null => false
        t.column "adjustment_type", :string,  :limit => 25,                :null => false
        t.column "adjustment_amt",  :integer,                 :null => false
        t.column "remarks",         :string
        t.column "lock_version",    :integer,  :default => 0, :null => false
        t.column "template_id",     :integer,                 :null => false
      end

      s.table "InvoiceAdjustments" do |t|
        t.column "system_ref",      :string,  :limit => 18,                :null => false
        t.column "item_ref",        :string,  :limit => 50,                :null => false
        t.column "document_id",     :string,  :limit => 20,                :null => false
        t.column "adjustment_type", :string,  :limit => 25,                :null => false
        t.column "adjustment_amt",  :integer,                 :null => false
        t.column "remarks",         :string
        t.column "lock_version",    :integer,  :default => 0, :null => false
      end

      s.table "InvoiceTemplates" do |t|
        t.column "item_id",       :integer,                 :null => false
        t.column "document_id",   :string,  :limit => 20,                :null => false
        t.column "document_date", :date,                                 :null => false
        t.column "due_amt",       :integer,                 :null => false
        t.column "remitted_amt",  :integer,                 :null => false
        t.column "tax_amt",       :integer
        t.column "document_type", :string,  :limit => 1,                 :null => false
        t.column "lock_version",  :integer,  :default => 0, :null => false
        t.column "template_id",   :integer,                 :null => false
      end

      s.table "Invoices" do |t|
        t.column "system_ref",    :string,  :limit => 18,                :null => false
        t.column "item_ref",      :string,  :limit => 50,                :null => false
        t.column "document_id",   :string,  :limit => 20,                :null => false
        t.column "document_date", :date,                                 :null => false
        t.column "due_amt",       :integer,                 :null => false
        t.column "remitted_amt",  :integer,                 :null => false
        t.column "tax_amt",       :integer,                 :null => false
        t.column "document_type", :string,  :limit => 1,                 :null => false
        t.column "lock_version",  :integer,  :default => 0, :null => false
      end

      s.table "OR_PROPERTIES" do |t|
        t.column "property_id",    :integer,  :null => false
        t.column "property_key",   :string,                :null => false
        t.column "property_value", :string
        t.index [:property_key], :name => :or_properties_uniq, :unique => true
      end

      s.table "OR_TAGS" do |t|
        t.column "tag_id",              :integer,  :null => false
        t.column "tagged_object_id",    :integer,  :null => false
        t.column "tagged_object_class", :string,                :null => false
        t.column "tag_value",           :string,                :null => false
        t.column "tag_type",            :string,                :null => false
        t.index [:tagged_object_id], :name => :or_tags_fk_1
      end

      s.table "OutGoingSecureMails" do |t|
        t.column "out_going_mail_id",       :integer,                  :null => false
        t.column "company_id",              :string,   :limit => 12,                :null => false
        t.column "secure_message_group_id", :string,   :limit => 12,                :null => false
        t.column "message_subject",         :string,   :limit => 50,                :null => false
        t.column "message_body",            :text,                                  :null => false
        t.column "sent_date_time",          :datetime,                              :null => false
        t.column "staff_id",                :string,   :limit => 50,                :null => false
        t.column "user_id",                 :string,   :limit => 50,                :null => false
        t.column "mail_status",             :string,   :limit => 1,                 :null => false
        t.column "lock_version",            :integer,   :default => 0, :null => false
        t.index [:company_id, :staff_id, :user_id], :name => :out_going_secure_mails_1_idx
      end

      s.table "PaperPayments" do |t|
        t.column "system_ref",                :string,   :limit => 18,                 :null => false
        t.column "debit_account_num",         :string,   :limit => 25,                 :null => false
        t.column "value_date",                :date,                                   :null => false
        t.column "company_id",                :string,   :limit => 12,                 :null => false
        t.column "advice_to_payee",           :string,   :limit => 146
        t.column "collection_mode",           :string,   :limit => 1,                  :null => false
        t.column "pickup_location_id",        :string,   :limit => 12
        t.column "transaction_status",        :string,   :limit => 35,                 :null => false
        t.column "scheduled_by_id",           :string,   :limit => 50,                 :null => false
        t.column "scheduled_date_time",       :datetime,                               :null => false
        t.column "mail_to_name",              :string,   :limit => 50
        t.column "financial_institution_ref", :string,   :limit => 18
        t.column "mail_to_address_id",        :integer
        t.column "sti_type",                  :string,                                 :null => false
        t.column "instruction_for_bank",      :string,   :limit => 146
        t.column "payment_currency_code",     :string,   :limit => 3
        t.column "payment_details",           :string,   :limit => 220
        t.column "template_version",          :integer
        t.column "payable_country_code",      :string,   :limit => 2
        t.column "transaction_amt",           :integer,                   :null => false
        t.column "lock_version",              :integer,    :default => 0, :null => false
        t.column "payee_id",                  :integer,                   :null => false
        t.column "internal_ref",              :string,   :limit => 35
        t.column "template_id",               :string,   :limit => 18
        t.index [:company_id, :scheduled_by_id, :debit_account_num], :name => :paper_payments_1_idx
      end

      s.table "Payees" do |t|
        t.column "payee_id",               :integer,                       :null => false
        t.column "payee_nick_name",        :string,   :limit => 35
        t.column "owner_id",               :string,   :limit => 12,                     :null => false
        t.column "payee_name",             :string,   :limit => 70,                     :null => false
        t.column "address_id",             :integer,                       :null => false
        t.column "system_added",           :boolean,                 :default => false, :null => false
        t.column "sti_type",               :string,                                     :null => false
        t.column "payee_fax",              :integer
        t.column "payee_type",             :string,   :limit => 1,                      :null => false
        t.column "account_num",            :string,   :limit => 25
        t.column "bank_internal_id",       :integer
        t.column "payee_status",           :string,   :limit => 1,   :default => "A",   :null => false
        t.column "currency_code",          :string,   :limit => 3
        t.column "payee_email",            :string,   :limit => 100
        t.column "last_updated_by_id",     :string,   :limit => 50
        t.column "last_updated_date_time", :datetime
        t.column "lock_version",           :integer,    :default => 0,     :null => false
      end

      s.table "PaymentTemplAndDetVersions" do |t|
        t.column "template_version_id",        :integer,                 :null => false
        t.column "template_detail_version_id", :integer,                 :null => false
        t.column "lock_version",               :integer,  :default => 0, :null => false
      end

      s.table "PaymentTemplateDetVersions" do |t|
        t.column "id",             :integer,                            :null => false
        t.column "field_name",   :string,  :limit => 30,                :null => false
        t.column "version",      :integer,                 :null => false
        t.column "field_req",    :boolean,                              :null => false
        t.column "field_locked", :boolean,                              :null => false
        t.column "field_value",  :string
        t.column "company_id",   :string,  :limit => 12,                :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
        t.column "template_id",  :string,  :limit => 18,                :null => false
      end

      s.table "PaymentTemplateDetails" do |t|
        t.column "field_name",     :string,  :limit => 30,                :null => false
        t.column "detail_version", :integer
        t.column "field_req",      :boolean,                              :null => false
        t.column "field_locked",   :boolean,                              :null => false
        t.column "field_value",    :string
        t.column "company_id",     :string,  :limit => 12,                :null => false
        t.column "lock_version",   :integer,  :default => 0, :null => false
        t.column "template_id",    :string,  :limit => 18,                :null => false
      end

      s.table "PaymentTemplateDrafts" do |t|
        t.column "id",                     :integer,                               :null => false
        t.column "company_id",             :string,   :limit => 12
        t.column "sti_type",               :string
        t.column "template_name",          :string,   :limit => 25
        t.column "description",            :string,   :limit => 50
        t.column "template_version",       :integer
        t.column "template_status",        :string,   :limit => 35
        t.column "template_details",       :text
        t.column "draft_for_new",          :boolean,                               :null => false
        t.column "transaction_type_id",    :string,   :limit => 12,                :null => false
        t.column "last_updated_by_id",     :string,   :limit => 50
        t.column "last_updated_date_time", :datetime
        t.column "lock_version",           :integer,   :default => 0, :null => false
        t.column "template_type",          :string,   :limit => 1,                 :null => false
        t.column "template_id",            :string,   :limit => 18
        t.index [:company_id, :template_name], :name => :paymt_templ_drafts_uniq_idx_1, :unique => true
      end

      s.table "PaymentTemplateVersions" do |t|
        t.column "id",                     :integer,                               :null => false
        t.column "company_id",             :string,   :limit => 12,                :null => false
        t.column "sti_type",               :string,                                :null => false
        t.column "template_name",          :string,   :limit => 25,                :null => false
        t.column "description",            :string,   :limit => 50
        t.column "version",                :integer,                  :null => false
        t.column "template_status",        :string,   :limit => 35,                :null => false
        t.column "transaction_type_id",    :string,   :limit => 12,                :null => false
        t.column "last_updated_by_id",     :string,   :limit => 50,                :null => false
        t.column "last_updated_date_time", :datetime,                              :null => false
        t.column "lock_version",           :integer,   :default => 0, :null => false
        t.column "template_type",          :string,   :limit => 1,                 :null => false
        t.column "template_id",            :string,   :limit => 18,                :null => false
      end

      s.table "PaymentTemplates" do |t|
        t.column "company_id",             :string,   :limit => 12,                :null => false
        t.column "sti_type",               :string,                                :null => false
        t.column "template_name",          :string,   :limit => 25,                :null => false
        t.column "description",            :string,   :limit => 50
        t.column "template_version",       :integer
        t.column "template_status",        :string,   :limit => 35,                :null => false
        t.column "transaction_type_id",    :string,   :limit => 12,                :null => false
        t.column "last_updated_by_id",     :string,   :limit => 50,                :null => false
        t.column "last_updated_date_time", :datetime,                              :null => false
        t.column "lock_version",           :integer,   :default => 0, :null => false
        t.column "template_type",          :string,   :limit => 1,                 :null => false
        t.column "template_id",            :string,   :limit => 18,                :null => false
        t.index [:company_id, :template_name], :name => :payment_templates_uniq_idx_1, :unique => true
      end

      s.table "PaymentTemplatesControl" do |t|
        t.column "company_id",   :string,  :limit => 12,                :null => false
        t.column "template_id",  :string,  :limit => 18,                :null => false
        t.column "lock_version", :integer,  :default => 0, :null => false
      end

      s.table "PaymentsFXDetails" do |t|
        t.column "system_ref",     :string,  :limit => 18,                                               :null => false
        t.column "fx_type",        :string,  :limit => 1,                                                :null => false
        t.column "special_rate",   :decimal,               :precision => 10, :scale => 6
        t.column "contract_1_ref", :string,  :limit => 50
        t.column "contract_2_ref", :string,  :limit => 50
        t.column "contract_3_ref", :string,  :limit => 50
        t.column "contract_1_amt", :integer
        t.column "contract_2_amt", :integer
        t.column "contract_3_amt", :integer
        t.column "lock_version",   :integer,                                 :default => 0, :null => false
      end

      s.table "PickupLocations" do |t|
        t.column "pickup_location_id",   :string,  :limit => 12,                :null => false
        t.column "pickup_location_name", :string,  :limit => 50,                :null => false
        t.column "address_id",           :integer,                 :null => false
        t.column "lock_version",         :integer,  :default => 0, :null => false
      end

      s.table "PreferredStdIntlBanks" do |t|
        t.column "bank_internal_id", :integer,                 :null => false
        t.column "company_id",       :string,  :limit => 12,                :null => false
        t.column "lock_version",     :integer,  :default => 0, :null => false
      end

      s.table "PreferredStdIntlPayees" do |t|
        t.column "company_id",      :string,  :limit => 12,                :null => false
        t.column "payee_nick_name", :string,  :limit => 35,                :null => false
        t.column "lock_version",    :integer,  :default => 0, :null => false
        t.column "payee_id",        :integer,                 :null => false
      end

      s.table "ProductSubTypeFieldMaps" do |t|
        t.column "product_sub_type_id",    :string,                      :null => false
        t.column "custom_field_name",      :string,  :limit => 35,                    :null => false
        t.column "custom_field_title",     :string,  :limit => 35,                    :null => false
        t.column "custom_field_data_type", :string,  :limit => 10,                    :null => false
        t.column "default_balance_field",  :boolean,               :default => false
        t.column "lock_version",           :integer,  :default => 0,     :null => false
      end

      s.table "ProductSubTypes" do |t|
        t.column "product_sub_type_id",            :string,  :limit => 20,                    :null => false
        t.column "product_sub_type_name",          :string,  :limit => 50,                    :null => false
        t.column "product_type_id",                :string,  :limit => 20,                    :null => false
        t.column "currency_code",                  :string,  :limit => 3
        t.column "product_sub_type_status",        :string,  :limit => 1,                     :null => false
        t.column "account_mask",                   :string,  :limit => 25
        t.column "account_mask_char",              :string,  :limit => 1
        t.column "transfer_from_opt",              :boolean,               :default => false, :null => false
        t.column "transfer_to_opt",                :boolean,               :default => false, :null => false
        t.column "bill_payment_opt",               :boolean,               :default => false, :null => false
        t.column "stop_payment_opt",               :boolean,               :default => false, :null => false
        t.column "other_payment_opt",              :boolean,               :default => false, :null => false
        t.column "tax_payment_opt",                :boolean,               :default => false, :null => false
        t.column "multi_currency_transaction_opt", :boolean,               :default => false, :null => false
        t.column "batch_opt",                      :boolean,               :default => false, :null => false
        t.column "register_days",                  :integer,                     :null => false
        t.column "lock_version",                   :integer,  :default => 0,     :null => false
      end

      s.table "ProductTypes" do |t|
        t.column "product_type_id",     :string,  :limit => 20,                :null => false
        t.column "product_type_name",   :string,  :limit => 50,                :null => false
        t.column "product_type_cat",    :string,  :limit => 9,                 :null => false
        t.column "currency_code",       :string,  :limit => 3,                 :null => false
        t.column "product_type_status", :string,  :limit => 1,                 :null => false
        t.column "lock_version",        :integer,  :default => 0, :null => false
      end

      s.table "Products" do |t|
        t.column "product_id",                     :string,  :limit => 20,                    :null => false
        t.column "product_name",                   :string,  :limit => 50,                    :null => false
        t.column "product_sub_type_id",            :string,  :limit => 20,                    :null => false
        t.column "currency_code",                  :string,  :limit => 3
        t.column "product_status",                 :string,  :limit => 1,                     :null => false
        t.column "account_mask_char",              :string,  :limit => 1
        t.column "account_mask",                   :string,  :limit => 25
        t.column "transfer_from_opt",              :boolean,               :default => false, :null => false
        t.column "transfer_to_opt",                :boolean,               :default => false, :null => false
        t.column "bill_payment_opt",               :boolean,               :default => false, :null => false
        t.column "stop_payment_opt",               :boolean,               :default => false, :null => false
        t.column "other_payment_opt",              :boolean,               :default => false, :null => false
        t.column "tax_payment_opt",                :boolean,               :default => false, :null => false
        t.column "multi_currency_transaction_opt", :boolean,               :default => false, :null => false
        t.column "batch_opt",                      :boolean,               :default => false, :null => false
        t.column "register_days",                  :integer
        t.column "lock_version",                   :integer,  :default => 0,     :null => false
      end

      s.table "QRTZ_BLOB_TRIGGERS" do |t|
        t.column "trigger_name",  :string, :limit => 80, :null => false
        t.column "trigger_group", :string, :limit => 80, :null => false
        t.column "blob_data",     :binary
      end

      s.table "QRTZ_CALENDARS" do |t|
        t.column "calendar_name", :string, :limit => 80, :null => false
        t.column "calendar",      :binary,               :null => false
      end

      s.table "QRTZ_CRON_TRIGGERS" do |t|
        t.column "trigger_name",    :string, :limit => 80, :null => false
        t.column "trigger_group",   :string, :limit => 80, :null => false
        t.column "cron_expression", :string, :limit => 80, :null => false
        t.column "time_zone_id",    :string, :limit => 80
      end

      s.table "QRTZ_FIRED_TRIGGERS" do |t|
        t.column "entry_id",          :string,  :limit => 95, :null => false
        t.column "trigger_name",      :string,  :limit => 80, :null => false
        t.column "trigger_group",     :string,  :limit => 80, :null => false
        t.column "is_volatile",       :string,  :limit => 1,  :null => false
        t.column "instance_name",     :string,  :limit => 80, :null => false
        t.column "fired_time",        :integer,  :null => false
        t.column "priority",          :integer,  :null => false
        t.column "state",             :string,  :limit => 16, :null => false
        t.column "job_name",          :string,  :limit => 80
        t.column "job_group",         :string,  :limit => 80
        t.column "is_stateful",       :string,  :limit => 1
        t.column "requests_recovery", :string,  :limit => 1,  :null => false
        t.index [:trigger_name, :trigger_group], :name => :qrtz_fired_triggers_idx_1
        t.index :is_volatile, :name => :qrtz_fired_triggers_idx_2
        t.index  [:instance_name], :name => :qrtz_fired_triggers_idx_3
        t.index [:job_name], :name => :qrtz_fired_triggers_idx_4
        t.index [:job_group], :name => :qrtz_fired_triggers_idx_5
        t.index [:is_stateful], :name => :qrtz_fired_triggers_idx_6
        t.index [:requests_recovery], :name => :qrtz_fired_triggers_idx_7
      end

      s.table "QRTZ_JOB_DETAILS" do |t|
        t.column "job_name",          :string, :limit => 80,  :null => false
        t.column "job_group",         :string, :limit => 80,  :null => false
        t.column "description",       :string, :limit => 120
        t.column "job_class_name",    :string, :limit => 128, :null => false
        t.column "is_durable",        :string, :limit => 1,   :null => false
        t.column "is_volatile",       :string, :limit => 1,   :null => false
        t.column "is_stateful",       :string, :limit => 1,   :null => false
        t.column "requests_recovery", :string, :limit => 1,   :null => false
        t.column "job_data",          :binary
        t.index :requests_recovery, :name => :qrtz_job_details_idx
      end

      s.table "QRTZ_JOB_LISTENERS" do |t|
        t.column "job_name",     :string, :limit => 80, :null => false
        t.column "job_group",    :string, :limit => 80, :null => false
        t.column "job_listener", :string, :limit => 80, :null => false
      end

      s.table "QRTZ_LOCKS" do |t|
        t.column "lock_name", :string, :null => false
      end

      s.table "QRTZ_PAUSED_TRIGGER_GRPS" do |t|
        t.column "trigger_group", :string, :limit => 80, :null => false
      end

      s.table "QRTZ_SCHEDULER_STATE" do |t|
        t.column "instance_name",     :string,  :limit => 80, :null => false
        t.column "last_checkin_time", :integer,  :null => false
        t.column "checkin_interval",  :integer,  :null => false
      end

      s.table "QRTZ_SIMPLE_TRIGGERS" do |t|
        t.column "trigger_name",    :string,  :limit => 80, :null => false
        t.column "trigger_group",   :string,  :limit => 80, :null => false
        t.column "repeat_count",    :integer,  :null => false
        t.column "repeat_interval", :integer,  :null => false
        t.column "times_triggered", :integer,  :null => false
      end

      s.table "QRTZ_TRIGGERS" do |t|
        t.column "trigger_name",   :string,  :limit => 80,  :null => false
        t.column "trigger_group",  :string,  :limit => 80,  :null => false
        t.column "job_name",       :string,  :limit => 80,  :null => false
        t.column "job_group",      :string,  :limit => 80,  :null => false
        t.column "is_volatile",    :string,  :limit => 1,   :null => false
        t.column "description",    :string,  :limit => 120
        t.column "next_fire_time", :integer,   :null => false
        t.column "prev_fire_time", :integer
        t.column "priority",       :integer
        t.column "trigger_state",  :string,  :limit => 16,  :null => false
        t.column "trigger_type",   :string,  :limit => 8,   :null => false
        t.column "start_time",     :integer,   :null => false
        t.column "end_time",       :integer
        t.column "calendar_name",  :string,  :limit => 80
        t.column "misfire_instr",  :integer
        t.column "job_data",       :binary
        t.index [:job_name, :job_group], :name => :qrtz_triggers_fk_1
        t.index [:next_fire_time], :name => :qrtz_triggers_idx_1
        t.index [:trigger_state], :name => :qrtz_triggers_idx_2
        t.index [:next_fire_time, :trigger_state], :name => :qrtz_triggers_idx_3
        t.index [:is_volatile], :name => :qrtz_triggers_idx_4
      end

      s.table "QRTZ_TRIGGER_LISTENERS" do |t|
        t.column "trigger_name",     :string, :limit => 80, :null => false
        t.column "trigger_group",    :string, :limit => 80, :null => false
        t.column "trigger_listener", :string, :limit => 80, :null => false
      end

      s.table "REPORT" do |t|
        t.column "report_id",        :integer,  :null => false
        t.column "name",             :string,                :null => false
        t.column "description",      :string,                :null => false
        t.column "report_file",      :string,                :null => false
        t.column "pdf_export",       :integer,  :null => false
        t.column "csv_export",       :integer,  :null => false
        t.column "xls_export",       :integer,  :null => false
        t.column "html_export",      :integer,  :null => false
        t.column "rtf_export",       :integer,  :null => false
        t.column "text_export",      :integer,  :null => false
        t.column "excel_export",     :integer,  :null => false
        t.column "image_export",     :integer,  :null => false
        t.column "fill_virtual",     :integer,  :null => false
        t.column "hidden_report",    :integer,  :null => false
        t.column "report_query",     :text
        t.column "datasource_id",    :integer
        t.column "chart_id",         :integer
        t.column "export_option_id", :integer
        t.index [:name], :name => :report_uniq, :unique => true
        t.index [:export_option_id], :name => :report_idx_1
        t.index [:datasource_id], :name => :report_idx_2
        t.index [:chart_id], :name => :report_idx_3
      end

      s.table "REPORT_ALERT" do |t|
        t.column "alert_id",      :integer,  :null => false
        t.column "name",          :string,                :null => false
        t.column "description",   :string,                :null => false
        t.column "alert_query",   :text,                  :null => false
        t.column "datasource_id", :integer
        t.index [:name], :name => :report_alert_uniq, :unique => true
        t.index [:datasource_id], :name => :report_alert_idx_1
      end

      s.table "REPORT_CHART" do |t|
        t.column "chart_id",         :integer,  :null => false
        t.column "name",             :string,                :null => false
        t.column "description",      :string,                :null => false
        t.column "chart_query",      :text,                  :null => false
        t.column "chart_type",       :integer,  :null => false
        t.column "width",            :integer,  :null => false
        t.column "height",           :integer,  :null => false
        t.column "x_axis_label",     :string
        t.column "y_axis_label",     :string
        t.column "show_legend",      :integer,  :null => false
        t.column "show_title",       :integer,  :null => false
        t.column "show_values",      :integer,  :null => false
        t.column "plot_orientation", :integer
        t.column "datasource_id",    :integer
        t.column "report_id",        :integer
        t.column "overlay_chart_id", :integer
        t.index [:name], :name => :report_chart_uniq, :unique => true
        t.index [:report_id], :name => :report_chart_idx_1
        t.index [:datasource_id], :name => :report_chart_idx_2
        t.index [:overlay_chart_id], :name => :report_chart_idx_3
      end

      s.table "REPORT_DATASOURCE" do |t|
        t.column "datasource_id",    :integer,  :null => false
        t.column "name",             :string,                :null => false
        t.column "driver",           :string
        t.column "url",              :string,                :null => false
        t.column "username",         :string
        t.column "password",         :string
        t.column "max_idle",         :integer
        t.column "max_active",       :integer
        t.column "max_wait",         :integer
        t.column "validation_query", :string
        t.column "jndi",             :integer
        t.index [:name], :name => :report_ds_uniq, :unique => true
      end

      s.table "REPORT_DELIVERY_LOG" do |t|
        t.column "delivery_log_id", :integer,   :null => false
        t.column "start_time",      :datetime
        t.column "end_time",        :datetime
        t.column "status",          :string
        t.column "message",         :text
        t.column "delivery_method", :string
        t.column "log_id",          :integer
        t.column "delivery_index",  :integer
        t.index [:log_id], :name => :report_delivery_log_idx_1
      end

      s.table "REPORT_EXPORT_OPTIONS" do |t|
        t.column "export_option_id",        :integer,  :null => false
        t.column "xls_remove_empty_space",  :integer,  :null => false
        t.column "xls_one_page_per_sheet",  :integer,  :null => false
        t.column "xls_auto_detect_cell",    :integer,  :null => false
        t.column "xls_white_background",    :integer,  :null => false
        t.column "html_remove_empty_space", :integer,  :null => false
        t.column "html_white_background",   :integer,  :null => false
        t.column "html_use_images",         :integer,  :null => false
        t.column "html_wrap_break",         :integer,  :null => false
      end

      s.table "REPORT_GROUP" do |t|
        t.column "group_id",    :integer,  :null => false
        t.column "name",        :string,                :null => false
        t.column "description", :string,                :null => false
        t.index :name, :name => :report_group_uniq, :unique => true
      end

      s.table "REPORT_GROUP_MAP" do |t|
        t.column "group_id",  :integer,  :null => false
        t.column "report_id", :integer,  :null => false
        t.column "map_id",    :integer,  :null => false
        t.index [:report_id], :name => :report_group_map_idx_1
        t.index [:group_id], :name => :report_group_map_idx_2
      end

      s.table "REPORT_LOG" do |t|
        t.column "log_id",      :integer,   :null => false
        t.column "start_time",  :datetime
        t.column "end_time",    :datetime
        t.column "status",      :string
        t.column "message",     :text
        t.column "export_type", :integer
        t.column "request_id",  :string
        t.column "report_id",   :integer
        t.column "user_id",     :integer
        t.column "alert_id",    :integer
        t.index [:user_id], :name => :report_log_idx_1
        t.index [:report_id], :name => :report_log_idx_2
        t.index [:alert_id], :name => :report_log_idx_3

        s.table "REPORT_PARAMETER" do |t|
          t.column "parameter_id",  :integer,  :null => false
          t.column "name",          :string,                :null => false
          t.column "type",          :string,                :null => false
          t.column "classname",     :string,                :null => false
          t.column "data",          :text,                  :null => false
          t.column "datasource_id", :integer,  :null => false
          t.column "description",   :string
          t.column "required",      :integer
          t.column "multi_select",  :integer
          t.column "default_value", :string
          t.index [:name], :name => :report_param_uniq, :unique => true
          t.index [:datasource_id], :name => :report_parameter_idx_1
        end

        s.table "REPORT_PARAMETER_MAP" do |t|
          t.column "report_id",    :integer,  :null => false
          t.column "parameter_id", :integer
          t.column "required",     :integer
          t.column "sort_order",   :integer
          t.column "step",         :integer
          t.column "map_id",       :integer,  :null => false
          t.index [:parameter_id], :name => :report_parameter_map_idx_1
          t.index [:report_id], :name => :report_parameter_map_idx_2
        end

        s.table "ReferenceSchemes" do |t|
          t.column "scheme_name",        :string,  :limit => 35,                :null => false
          t.column "scheme_pattern",     :string,  :limit => 50,                :null => false
          t.column "cycle_frequency",    :string,  :limit => 1,                 :null => false
          t.column "minimum_value",      :integer
          t.column "maximum_value",      :integer
          t.column "current_value",      :integer,  :default => 0, :null => false
          t.column "lock_version",       :integer,  :default => 0, :null => false
          t.column "last_recycled_date", :date
        end

        s.table "RestrictedTemplateACLs" do |t|
          t.column "company_id",  :string, :limit => 12, :null => false
          t.column "user_id",     :string, :limit => 50, :null => false
          t.column "template_id", :string, :limit => 18, :null => false
        end

        s.table "Roles" do |t|
          t.column "id",                :integer,                              :null => false
          t.column "name",              :string,  :limit => 50,                :null => false
          t.column "authorizable_type", :string
          t.column "authorizable_id",   :string,  :limit => 50
          t.column "lock_version",      :integer,  :default => 0, :null => false
        end

        s.table "RolesUserProfiles" do |t|
          t.column "user_profile_id", :string,  :limit => 65,                :null => false
          t.column "role_id",         :integer,                 :null => false
          t.column "lock_version",    :integer,  :default => 0, :null => false
        end

        s.table "SecureMessageGroups" do |t|
          t.column "secure_message_group_id", :string,  :limit => 12,                :null => false
          t.column "description",             :string,  :limit => 50,                :null => false
          t.column "lock_version",            :integer,  :default => 0, :null => false
        end

        s.table "ServicePermissionLimits" do |t|
          t.column "user_profile_id",       :string,  :limit => 65,                :null => false
          t.column "service_permission_id", :string,  :limit => 35,                :null => false
          t.column "service_id",            :string,  :limit => 18,                :null => false
          t.column "transaction_limit_amt", :integer,                 :null => false
          t.column "daily_limit_amt",       :integer,                 :null => false
          t.column "lock_version",          :integer,  :default => 0, :null => false
        end

        s.table "ServicePermissions" do |t|
          t.column "service_permission_id", :string,  :limit => 35,                :null => false
          t.column "service_id",            :string,  :limit => 18,                :null => false
          t.column "lock_version",          :integer,  :default => 0, :null => false
        end

        s.table "Services" do |t|
          t.column "service_id",   :string,  :limit => 18,                :null => false
          t.column "lock_version", :integer,  :default => 0, :null => false
        end

        s.table "SignatureGroupCombDetails" do |t|
          t.column "signature_group_combination_id", :integer,                 :null => false
          t.column "company_id",                     :string,  :limit => 12,                :null => false
          t.column "signature_group_id",             :string,  :limit => 12,                :null => false
          t.column "signature_tally",                :integer,  :default => 1, :null => false
          t.column "lock_version",                   :integer,  :default => 0, :null => false
        end

        s.table "SignatureGroupCombinations" do |t|
          t.column "signature_group_combination_id", :integer,                 :null => false
          t.column "lock_version",                   :integer,  :default => 0, :null => false
        end

        s.table "SignatureGroups" do |t|
          t.column "signature_group_id", :string,  :limit => 12,                :null => false
          t.column "company_id",         :string,  :limit => 12,                :null => false
          t.column "description",        :string,  :limit => 50,                :null => false
          t.column "lock_version",       :integer,  :default => 0, :null => false
        end

        s.table "SignatureParameters" do |t|
          t.column "signature_parameter_id", :integer,                 :null => false
          t.column "class_id",               :string,  :limit => 12,                :null => false
          t.column "transaction_type_id",    :string,  :limit => 12,                :null => false
          t.column "account_num",            :string,  :limit => 25
          t.column "sti_type",               :string,  :limit => 50,                :null => false
          t.column "lock_version",           :integer,  :default => 0, :null => false
          t.index [:class_id, :transaction_type_id, :account_num], :name => :signatureparam_uniq_idx_1, :unique => true
        end

        s.table "SimpleTransformFieldMaps" do |t|
          t.column "business_field_name",          :string,  :limit => 30,                    :null => false
          t.column "transaction_type_id",          :string,  :limit => 12,                    :null => false
          t.column "source_field_name",            :string,  :limit => 30
          t.column "source_field_type",            :string,  :limit => 20
          t.column "source_field_seq",             :integer,  :default => 0,     :null => false
          t.column "source_field_length",          :integer,  :default => 0,     :null => false
          t.column "source_field_format",          :string,  :limit => 50
          t.column "source_field_mandatory",       :boolean,               :default => false, :null => false
          t.column "transformation_definition_id", :string,  :limit => 65,                    :null => false
          t.column "source_field_start_pos",       :integer,  :default => 0,     :null => false
          t.column "source_field_end_pos",         :integer,  :default => 0,     :null => false
          t.column "default_value",                :string,  :limit => 50
          t.column "lock_version",                 :integer,  :default => 0,     :null => false
        end

        s.table "SimpleTransformationParams" do |t|
          t.column "input_file_type",              :string,  :limit => 25,                    :null => false
          t.column "record_length",                :integer,  :default => 0,     :null => false
          t.column "delimiter_character",          :string,  :limit => 5
          t.column "transformation_definition_id", :string,  :limit => 65,                    :null => false
          t.column "header_row_present",           :boolean,               :default => false, :null => false
          t.column "lock_version",                 :integer,  :default => 0,     :null => false
        end

        s.table "StaffRoles" do |t|
          t.column "id",                :integer,                              :null => false
          t.column "name",              :string,  :limit => 50,                :null => false
          t.column "authorizable_type", :string
          t.column "authorizable_id",   :string,  :limit => 50
          t.column "lock_version",      :integer,  :default => 0, :null => false
        end

        s.table "StaffRolesSupportGroups" do |t|
          t.column "support_group_id", :string,  :limit => 65,                :null => false
          t.column "staff_role_id",    :integer,                 :null => false
          t.column "lock_version",     :integer,  :default => 0, :null => false
        end

        s.table "Staffs" do |t|
          t.column "staff_id",        :string,  :limit => 50,                :null => false
          t.column "staff_status",    :string,  :limit => 1,                 :null => false
          t.column "lock_version",    :integer,  :default => 0, :null => false
          t.column "report_group_id", :integer
        end

        s.table "SupportGroups" do |t|
          t.column "support_group_id",        :string,  :limit => 12,                :null => false
          t.column "description",             :string,  :limit => 25,                :null => false
          t.column "secure_message_group_id", :string,  :limit => 12,                :null => false
          t.column "support_group_status",    :string,  :limit => 1,                 :null => false
          t.column "lock_version",            :integer,  :default => 0, :null => false
        end

        s.table "SupportStaffEntitlements" do |t|
          t.column "staff_id",         :string,  :limit => 50,                :null => false
          t.column "support_group_id", :string,  :limit => 12,                :null => false
          t.column "lock_version",     :integer,  :default => 0, :null => false
        end

        s.table "TransactionNotes" do |t|
          t.column "created_date_time", :datetime,                                :null => false
          t.column "created_micro_sec", :integer,                    :null => false
          t.column "user_id",           :string,   :limit => 50,                  :null => false
          t.column "system_ref",        :string,   :limit => 18,                  :null => false
          t.column "notes",             :string,   :limit => 4000,                :null => false
          t.column "lock_version",      :integer,     :default => 0, :null => false
          t.index [:system_ref], :name => :transaction_notes_1_idx
        end

        s.table "TransactionRoutings" do |t|
          t.column "system_ref",   :string,  :limit => 18,                :null => false
          t.column "user_id",      :string,  :limit => 50,                :null => false
          t.column "routing_seq",  :integer,                 :null => false
          t.column "lock_version", :integer,  :default => 0, :null => false
        end

        s.table "TransactionSignatories" do |t|
          t.column "system_ref",   :string,  :limit => 18,                :null => false
          t.column "user_id",      :string,  :limit => 50,                :null => false
          t.column "lock_version", :integer,  :default => 0, :null => false
        end

        s.table "TransactionTypes" do |t|
          t.column "transaction_type_id",     :string,  :limit => 12,                               :null => false
          t.column "description",             :string,  :limit => 50,                               :null => false
          t.column "cutoff_time",             :time
          t.column "weekend_cutoff_time",     :time
          t.column "holidays_applicable",     :boolean,               :default => true,             :null => false
          t.column "transaction_type_status", :string,  :limit => 1,                                :null => false
          t.column "transaction_type_cat",    :string,  :limit => 1,                                :null => false
          t.column "lock_version",            :integer,  :default => 0,                :null => false
          t.column "scheme_name",             :string,  :limit => 35, :default => "DEFAULT_SCHEME", :null => false
        end

        s.table "Transfers" do |t|
          t.column "system_ref",                :string,   :limit => 18,                :null => false
          t.column "debit_account_num",         :string,   :limit => 25,                :null => false
          t.column "credit_account_num",        :string,   :limit => 25,                :null => false
          t.column "value_date",                :date,                                  :null => false
          t.column "transaction_status",        :string,   :limit => 35,                :null => false
          t.column "financial_institution_ref", :string,   :limit => 18
          t.column "internal_ref",              :string,   :limit => 35
          t.column "scheduled_by_id",           :string,   :limit => 50,                :null => false
          t.column "scheduled_date_time",       :datetime,                              :null => false
          t.column "company_id",                :string,   :limit => 12,                :null => false
          t.column "transaction_amt",           :integer,                  :null => false
          t.column "lock_version",              :integer,   :default => 0, :null => false
          t.index [:company_id, :debit_account_num, :scheduled_by_id], :name => :transfers_1_idx
        end

        s.table "TransformationDefinitions" do |t|
          t.column "transformation_definition_id", :string,   :limit => 65,                 :null => false
          t.column "transformation_defn_name",     :string,   :limit => 50,                 :null => false
          t.column "company_id",                   :string,   :limit => 12
          t.column "description",                  :string,   :limit => 100
          t.column "file_content_id",              :integer
          t.column "transformation_defn_type",     :string,   :limit => 7,                  :null => false
          t.column "transformation_defn_status",   :string,   :limit => 1,                  :null => false
          t.column "transformation_defn_version",  :integer,                   :null => false
          t.column "last_updated_by_id",           :string,   :limit => 50,                 :null => false
          t.column "last_updated_date_time",       :datetime,                               :null => false
          t.column "lock_version",                 :integer,    :default => 0, :null => false
          t.index [:transformation_defn_name, :company_id], :name => :transformation_def_uniq_idx_1, :unique => true
        end

        s.table "TransformationTxnTypes" do |t|
          t.column "transaction_type_id",          :string,  :limit => 12,                :null => false
          t.column "transformation_definition_id", :string,  :limit => 65,                :null => false
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end

        s.table "USER_ALERT_MAP" do |t|
          t.column "user_id",        :integer,  :null => false
          t.column "alert_id",       :integer
          t.column "report_id",      :integer
          t.column "alert_limit",    :integer
          t.column "alert_operator", :string
          t.column "map_id",         :integer,  :null => false
          t.index [:user_id], :name => :user_alert_map_idx_1
          t.index [:report_id], :name => :user_alert_map_idx_2
          t.index [:alert_id], :name => :user_alert_map_idx_3
        end

        s.table "USER_GROUP_MAP" do |t|
          t.column "user_id",  :integer,  :null => false
          t.column "group_id", :integer,  :null => false
          t.column "map_id",   :integer,  :null => false
          t.index [:user_id], :name => :user_group_map_idx_1
          t.index [:group_id], :name => :user_group_map_idx_2
        end

        s.table "USER_SECURITY" do |t|
          t.column "user_id",   :integer,  :null => false
          t.column "role_name", :string,                :null => false
        end

        s.table "UserAccountPreferences" do |t|
          t.column "user_id",      :string,  :limit => 50,                :null => false
          t.column "account_num",  :string,  :limit => 25,                :null => false
          t.column "lock_version", :integer,  :default => 0, :null => false
        end

        s.table "UserProfiles" do |t|
          t.column "user_profile_id",        :string,   :limit => 65,                :null => false
          t.column "user_profile_name",      :string,   :limit => 65,                :null => false
          t.column "sti_type",               :string,                                :null => false
          t.column "last_updated_by_id",     :string,   :limit => 50,                :null => false
          t.column "last_updated_date_time", :datetime,                              :null => false
          t.column "lock_version",           :integer,   :default => 0, :null => false
          t.column "report_group_id",        :integer
          t.index [:user_profile_name], :name => :user_profiles_uniq_idx_1, :unique => true
        end

        s.table "Users" do |t|
          t.column "user_id",          :string,  :limit => 50,                 :null => false
          t.column "user_first_name",  :string,  :limit => 50,                 :null => false
          t.column "user_middle_name", :string,  :limit => 50
          t.column "user_last_name",   :string,  :limit => 50
          t.column "user_email",       :string,  :limit => 100
          t.column "user_phone",       :integer
          t.column "lock_version",     :integer,   :default => 0, :null => false
        end

        s.table "WHTCTemplateDetails" do |t|
          t.column "item_id",               :integer,                                                 :null => false
          t.column "certificate_id",        :string,  :limit => 20,                                                :null => false
          t.column "certificate_detail_id", :string,  :limit => 20,                                                :null => false
          t.column "base_amt",              :integer,                                                 :null => false
          t.column "wht_amt",               :integer,                                                 :null => false
          t.column "income_type",           :string,  :limit => 40
          t.column "deduction_rate",        :decimal,                :precision => 10, :scale => 2,                :null => false
          t.column "income_description",    :string,  :limit => 100
          t.column "lock_version",          :integer,                                  :default => 0, :null => false
          t.column "template_id",           :integer,                                                 :null => false
        end

        s.table "WHTCTemplates" do |t|
          t.column "item_id",        :integer,                  :null => false
          t.column "certificate_id", :string,  :limit => 20,                 :null => false
          t.column "form_type",      :string,  :limit => 2
          t.column "total_base_amt", :integer,                  :null => false
          t.column "total_wht_amt",  :integer,                  :null => false
          t.column "payer_tax_id",   :string,  :limit => 15
          t.column "payee_tax_id",   :string,  :limit => 15
          t.column "payer_name",     :string,  :limit => 150
          t.column "payer_addr",     :string,  :limit => 200
          t.column "payee_name",     :string,  :limit => 150
          t.column "payee_addr",     :string,  :limit => 200
          t.column "payment_type",   :string,  :limit => 1
          t.column "lock_version",   :integer,   :default => 0, :null => false
          t.column "template_id",    :integer,                  :null => false
        end

        s.table "WHTCertificateDetails" do |t|
          t.column "system_ref",            :string,  :limit => 18,                                                :null => false
          t.column "item_ref",              :string,  :limit => 50,                                                :null => false
          t.column "certificate_id",        :string,  :limit => 20,                                                :null => false
          t.column "certificate_detail_id", :string,  :limit => 20,                                                :null => false
          t.column "base_amt",              :integer,                                                 :null => false
          t.column "wht_amt",               :integer,                                                 :null => false
          t.column "income_type",           :string,  :limit => 40
          t.column "deduction_rate",        :decimal,                :precision => 10, :scale => 2,                :null => false
          t.column "income_description",    :string,  :limit => 100
          t.column "lock_version",          :integer,                                  :default => 0, :null => false
        end

        s.table "WHTCertificates" do |t|
          t.column "system_ref",     :string,  :limit => 18,                 :null => false
          t.column "item_ref",       :string,  :limit => 50,                 :null => false
          t.column "certificate_id", :string,  :limit => 20,                 :null => false
          t.column "form_type",      :string,  :limit => 2
          t.column "total_base_amt", :integer,                  :null => false
          t.column "total_wht_amt",  :integer,                  :null => false
          t.column "payer_tax_id",   :string,  :limit => 15
          t.column "payee_tax_id",   :string,  :limit => 15
          t.column "payer_name",     :string,  :limit => 150
          t.column "payer_addr",     :string,  :limit => 200
          t.column "payee_name",     :string,  :limit => 150
          t.column "payee_addr",     :string,  :limit => 200
          t.column "payment_type",   :string,  :limit => 1
          t.column "lock_version",   :integer,   :default => 0, :null => false
        end

        s.table "WorkflowParameters" do |t|
          t.column "transaction_type_id",        :string,  :limit => 12,                :null => false
          t.column "class_id",                   :string,  :limit => 12,                :null => false
          t.column "verification_req",           :integer 
          t.column "signature_req",              :integer 
          t.column "release_req",                :integer 
          t.column "cutoff_time_offset_in_mins", :integer 
          t.column "sti_type",                   :string,  :limit => 70,                :null => false
          t.column "daily_limit_amt",            :integer 
          t.column "transaction_limit_amt",      :integer 
          t.column "param_status",               :string,  :limit => 1
          t.column "lock_version",               :integer,  :default => 0, :null => false
          t.index [:param_status], :name => :workflow_parameters_1_idx
        end

        s.table "XformSubscribedClasses" do |t|
          t.column "transformation_definition_id", :string,  :limit => 65,                :null => false
          t.column "class_id",                     :string,  :limit => 12,                :null => false
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end

        s.table "XformSubscribedCompanies" do |t|
          t.column "transformation_definition_id", :string,  :limit => 65,                :null => false
          t.column "company_id",                   :string,  :limit => 12,                :null => false
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end
      
        s.table "ChangeLogs" do |t|
          t.column "change_log_id", :integer,      :null => false
          t.column "record_type",                  :text,     :null => false
          t.column "record_id",                    :string, :limit => 125,   :null => false
          t.column "verb",                         :text,   :null => false
          t.column "created_at",                   :datetime,     :null => false
          t.column "user_id",                      :string,  :limit => 50,   :null => false
          t.column "owner_id",                     :string,  :limit => 12,   :null => false
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end
        
        s.table "ClauseDefinitions" do |t|
          t.column "clause_id",          :string, :limit => 50, :null => false
          t.column "description",                  :string, :limit => 255,:null => true
          t.column "clause_type_id",               :string, :limit => 50, :null => false
          t.column "clause_text",                  :binary,   :null => true
          t.column "mandatory_flag",               :string, :limit => 1, :default => '0',  :null => false
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end
        
        s.table "ClauseDefinitionSubFields" do |t|
          t.column "clause_id",          :string, :limit => 50, :null => false
          t.column "sub_field_id",                 :string, :limit => 50, :null => false
          t.column "sub_field_seq",           :integer, :null => false
          t.column "sub_field_default",            :string, :limit => 255,   :null => true
          t.column "mandatory_flag",               :string, :limit => 1,  :default => nil, :null => true
          t.column "lock_version",                 :integer,  :default => 0, :null => false
        end

  s.table :ClauseSubFieldDefinitions do |t|
    t.column  :sub_field_id,      :string, :limit => 50,                :null => false
    t.column  :sub_field_name,    :string, :limit => 50,                :null => false
    t.column  :sub_field_type,    :string, :limit => 3,                 :null => false
    t.column :sub_field_length,   :integer,             :default => 0
    t.column  :sub_field_default, :string
    t.column  :sub_field_options, :string
    t.column :mandatory_flag, :string, :limit => 1,                 :default => '0', :null => false
    t.column :lock_version, :integer,                    :default => 0, :null => false
  end

  s.table :ClauseTypes do |t|
    t.column  :clause_type_id, :string, :limit => 50,                 :null => false
    t.column  :description,    :string, :limit => 100,                :null => false
    t.column :lock_version, :integer,                 :default => 0, :null => false
  end

  s.table :CountryTradeTranTypes do |t|
    t.column :country_code, :string, :limit => 2,                 :null => false
    t.column  :transaction_type_id, :string, :limit => 12,                :null => false
    t.column :lock_version, :integer,               :default => 0, :null => false
  end

  s.table :CountryTranTypeClauseDefns do |t|
    t.column  :country_code,        :string, :limit => 2,                  :null => false
    t.column  :transaction_type_id,        :string, :limit => 12,                 :null => false
    t.column  :clause_id, :string, :limit => 50,                 :null => false
    t.column :display_seq, :integer,                                  :null => false
    t.column :mandatory_flag, :string,                    :limit => 1, :default => nil, :null => true
    t.column :lock_version, :integer,                      :default => 0,  :null => false
  end

  s.table :CountryTranTypeClauseTypes do |t|
    t.column  :country_code,     :string, :limit => 2,                 :null => false
    t.column  :transaction_type_id,     :string, :limit => 12,                :null => false
    t.column  :clause_type_id,   :string, :limit => 50,                :null => false
    t.column :display_seq, :integer,                              :null => false
    t.column :lock_version,  :integer,                 :default => 0, :null => false
  end

    s.table :LcClauses do |t|
      t.column :system_ref, :string, :limit => 18, :null => false      
      t.column :clause_id, :string, :limit => 50, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :LcClauseSubFields do |t|
      t.column :system_ref, :string, :limit => 18, :null => false      
      t.column :clause_id, :string, :limit => 50, :null => false
      t.column :sub_field_id, :string, :limit => 50, :null => false
      t.column :sub_field_seq, :integer, :null => false
      t.column :sub_field_value, :string, :limit => 255, :null => true
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :Parties do |t|
      t.column :party_id, :integer, :null => false
      t.column :party_name, :string, :limit => 50, :null => false
      t.column :company_id, :string, :limit => 12, :null => false
      t.column :party_status, :string, :limit => 1, :null => false
      t.column :address_id, :integer, :null => false
      t.column :party_pnone, :integer, :null => true
      t.column :party_mobile, :integer, :null => true
      t.column :party_email, :string, :limit => 100, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.index [:party_name, :company_id], :name => "party_uniq_idx", :unique => true
    end

    s.table :CreditFacilities do |t|
      t.column :credit_facility_ref, :string, :limit => 18, :null => false
      t.column :company_id, :string, :limit => 12, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :IncoTerms do |t|
      t.column :inco_term_code, :string, :limit => 3, :null => false
      t.column :description, :string, :limit => 50, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :LettersOfCredit do |t|
      t.column :system_ref, :string, :limit => 18, :null => false
      t.column :application_date, :date, :null => false
      t.column :lc_ref, :string, :limit => 30, :null => true
      t.column :on_behalf_of_id, :integer, :null => true
      t.column :contact_person_name, :string, :limit => 100, :null => true
      t.column :credit_facility_ref, :string, :limit => 50, :null => true
      t.column :charges_debit_account_num, :string, :limit => 25, :null => false
      t.column :lc_revocable, :string, :limit => 1, :null => false
      t.column :lc_transferable, :string, :limit => 1, :null => false
      t.column :currency_code, :string, :limit => 3, :null => false
      t.column :transaction_amt, :integer, :null => false
      t.column :payee_id, :integer, :null => false
      t.column :tenor_type_id, :string, :limit => 3, :null => false
      t.column :tenor_period_in_days, :integer, :null => false
      t.column :positive_tolerance_percent, :decimal, :precision => 10, :scale => 6, :null => false
      t.column :negative_tolerance_percent, :decimal, :precision => 10, :scale => 6, :null => false
      t.column :lc_expiry_date, :date, :null => false
      t.column :lc_expiry_country_code, :string, :limit => 2, :null => false
      t.column :lc_expiry_city_name, :string, :limit => 50, :null => true
      t.column :lc_part_shipment, :string, :limit => 1, :null => false
      t.column :lc_trans_shipment, :string, :limit => 1, :null => false
      t.column :last_shipment_date, :date, :null => false
      t.column :advise_medium, :string, :limit =>1, :null => false
      t.column :ship_from_city_name, :string, :limit => 50, :null => false
      t.column :ship_to_city_name, :string, :limit => 50, :null => false
      t.column :inco_term_id, :string, :limit => 3, :null => false
      t.column :transaction_status, :string, :limit => 35, :null => false
      t.column :scheduled_by_id, :string, :limit => 50, :null => false
      t.column :scheduled_date_time, :datetime, :null => false
      t.column :company_id, :string, :limit => 12, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :issuance_date, :date, :null => true
      t.column :file_content_id, :integer, :null => true
      t.column :amendment_cnt, :integer, :default => 0, :null => false
    end

    s.table :LCAmendments do |t|
      t.column :system_ref, :string, :limit => 18, :null => false
      t.column :application_date, :date, :null => false
      t.column :lc_ref, :string, :limit => 30, :null => false
      t.column :amendment_seq, :integer, :null => false
      t.column :amendment_ref, :string, :limit => 30, :null => true
      t.column :company_id, :string, :limit => 12, :null => false 
      t.column :transaction_status, :string, :limit => 35, :null => false
      t.column :scheduled_by_id, :string, :limit => 50, :null => false
      t.column :scheduled_date_time, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :LCAmendmentDetails do |t|
      t.column :system_ref, :string, :limit => 18, :null => false
      t.column :lc_attribute_name, :string, :limit => 30, :null => false
      t.column :lc_attribute_old_value, :string, :limit => 100, :null => false
      t.column :lc_attribute_new_value, :string, :limit => 100, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :LCAmendmentClauses do |t|
      t.column :system_ref, :string, :limit => 18, :null => false
      t.column :clause_id, :string, :limit => 50, :null => false
      t.column :amendment_type, :string, :limit => 1, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :LCAmendClauseSubFields do |t|
      t.column :system_ref, :string, :limit => 18, :null => false
      t.column :clause_id, :string, :limit => 50, :null => false
      t.column :sub_field_id, :string, :limit => 50, :null => false
      t.column :sub_field_seq, :integer, :null => false
      t.column :sub_field_value, :string, :limit => 255, :null => true
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :BusinessRuleTemplates do |t|
      t.column :rule_template_id, :string, :limit => 30, :null => false
      t.column :description, :string, :limit => 50, :null => false
      t.column :rule_template_file_content_id, :integer, :null => false
      t.column :narrative, :text, :null => true
      t.column :sample_xls_file_content_id, :integer, :null => true
      t.column :created_date_time, :datetime, :null => false
      t.column :created_by_user_id, :string, :limit => 20, :null => false
      t.column :template_category, :string, :limit => 1, :default => 'S', :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :Fees do |t|
      t.column :fee_id, :integer, :null => false
      t.column :company_id, :string, :limit => 12, :null => false
      t.column :fee_particulars, :string, :limit => 255, :null => false
      t.column :credit_debit_indicator, :string, :limit => 15, :null => false
      t.column :fee_amt, :integer, :null => false
      t.column :created_date_time, :datetime, :null => false
      t.column :created_by_user_id, :string, :limit => 20, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

    s.table :FeeConfiguration do |t|
      t.column :class_id, :string, :limit => 12, :null => false
      t.column :rule_template_id, :string, :limit => 255, :null => false
      t.column :xls_file_content_id, :integer, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end

  s.table :ImportBills do |t|
    t.column   :system_ref,           :string, :limit => 18,                 :null => false
    t.column   :bill_date,            :date,                                 :null => false
    t.column   :bill_due_date,        :date
    t.column   :currency_code,        :string, :limit => 3,                  :null => false
    t.column   :transaction_amt,      :integer,                              :null => false
    t.column   :payee_id,             :integer,                              :null => false
    t.column   :payee_bank_name,      :string, :limit => 100
    t.column   :payee_bank_ref,       :string, :limit => 50
    t.column   :tenor_type,           :string, :limit => 3,                  :null => false
    t.column   :tenor_period_in_days, :integer
    t.column   :ship_from_city_name,  :string, :limit => 50,                 :null => false
    t.column   :carrier_id,           :string, :limit => 15,                 :null => false
    t.column   :consignment_ref,      :string, :limit => 50,                 :null => false
    t.column   :consignment_date,     :date,                                 :null => false
    t.column   :transaction_status,   :string, :limit => 35,                 :null => false
    t.column   :scheduled_by_id,      :string, :limit => 50,                 :null => false
    t.column   :scheduled_date_time,  :datetime,                             :null => false
    t.column   :company_id,           :string, :limit => 12,                 :null => false
    t.column   :lock_version,         :integer,               :default => 0, :null => false
  end

  s.table :LCBills do |t|
    t.column  :lc_ref,          :string, :limit => 18,                :null => false
    t.column  :company_id,      :string, :limit => 12,                :null => false
    t.column  :bill_system_ref, :string, :limit => 18,                :null => false
    t.column  :lock_version,    :integer,              :default => 0, :null => false
  end

  s.table :SettlementInstructions do |t|
    t.column  :system_ref,      :string, :limit => 18,                :null => false
    t.column  :company_id,      :string, :limit => 12,                :null => false
    t.column  :clause_set_id, :integer
    t.column  :bill_system_ref, :string, :limit => 18
    t.column  :lock_version, :integer,                 :default => 0, :null => false
  end

  s.table :ShippingGuarantees do |t|
    t.column  :shipping_guarantee_ref,  :string, :limit => 30, :null => false
    t.column  :company_id,              :string, :limit => 12,                 :null => false
    t.column  :shipping_guarantee_date, :date,                              :null => false
    t.column :lock_version, :integer,                          :default => 0,  :null => false
  end

  s.table :SGApplications do |t|
    t.column   :system_ref,                :string, :limit => 18,                 :null => false
    t.column   :application_date,          :date,                                 :null => false
    t.column   :shipping_guarantee_ref,    :string, :limit => 30
    t.column   :on_behalf_of_id, :integer
    t.column   :contact_person_name,       :string, :limit => 100
    t.column   :credit_facility_ref,       :string, :limit => 50
    t.column   :charges_debit_account_num, :string, :limit => 25,                 :null => false
    t.column   :lc_ref,                    :string, :limit => 30
    t.column   :company_id,                :string, :limit => 12,                 :null => false
    t.column   :currency_code,             :string, :limit => 3,                  :null => false
    t.column   :transaction_amt,           :integer,                              :null => false
    t.column   :consignment_ref,           :string, :limit => 50,                 :null => false
    t.column   :consignment_date,          :date,                                 :null => false
    t.column   :carrier_company_name,      :string, :limit => 100,                :null => false
    t.column   :carrier_id,                :string, :limit => 15,                 :null => false
    t.column   :invoice_num,               :string, :limit => 25
    t.column   :settlement_type,           :string, :limit => 1,                  :null => false
    t.column   :merchandise,               :text 
    t.column   :transaction_status,        :string, :limit => 35,                 :null => false
    t.column   :scheduled_by_id,           :string, :limit => 50,                 :null => false
    t.column   :scheduled_date_time,       :datetime,                              :null => false
    t.column   :settlement_system_ref,     :string, :limit => 12,                 :null => true
    t.column   :lock_version,              :integer,               :default => 0, :null => false
  end
  
  s.table :TenorTypes do |t|
    t.column :tenor_type_id, :string, :limit => 3, :null  => false
    t.column :description, :string, :limit => 35, :null => false
    t.column :lock_version, :integer, :default => 0, :null => false
  end

        ######################
        #Views in the schema
        ######################
        
        s.view "PaymentTemplateWorkItems" do |t|
          t.column "template_id"
          t.column "company_id"
          t.column "sti_type"
          t.column "template_name"
          t.column "description"
          t.column "last_updated_by_id"
          t.column "last_updated_date_time"
          t.column "template_version"
          t.column "template_status"
          t.column "transaction_type_id"
          t.column "template_type"
        end

        s.view "AuthorizedIntlBanks" do |t|
          t.column "bank_internal_id"
          t.column "bank_class"
          t.column "bank_name"
          t.column "company_id"
          t.column "last_updated_by_id"
          t.column "system_added"
          t.column "location_addr"
          t.column "city_name"
          t.column "state_name"
          t.column "postal_code"
          t.column "country_code"
        end

        s.view "AuthorizedIntlPayees" do |t|
          t.column "company_id"
          t.column "payee_id"
          t.column "payee_nick_name"
          t.column "payee_name"
          t.column "account_num"
          t.column "currency_code"
          t.column "payee_class"
          t.column "last_updated_by_id"
          t.column "payee_type"
          t.column "bank_internal_id"
          t.column "system_added"
          t.column "address_id"
          t.column "payee_email"
          t.column "payee_fax"
        end

        s.view "CompTransformationDefinitions" do |t|
          t.column :transformation_definition_id
          t.column :transformation_defn_name
          t.column :company_id
          t.column :description
          t.column :file_content_id
          t.column :transformation_defn_type
          t.column :transformation_defn_status
          t.column :transformation_defn_version
          t.column :last_updated_by_id
          t.column :last_updated_date_time
          t.column :owner_id
        end

        s.view "InternationalPayments" do |t|
          t.column :system_ref
          t.column :internal_ref
          t.column :debit_account_num
          t.column :value_date
          t.column :currency_code
          t.column :transaction_type_id
          t.column :payee_id
          t.column :payee_bank_id
          t.column :transaction_amt
          t.column :transaction_status
          t.column :scheduled_by_id
          t.column :company_id
          t.column :transaction_type_description
          t.column :payee_name
          t.column :scheduled_by_user_name
        end

        s.view "LocalPayments" do |t|
          t.column :system_ref
          t.column :internal_ref
          t.column :debit_account_num
          t.column :value_date
          t.column :currency_code
          t.column :transaction_type_id
          t.column :payee_id
          t.column :payee_bank_id
          t.column :transaction_amt
          t.column :transaction_status
          t.column :scheduled_by_id
          t.column :company_id
          t.column :transaction_type_description
          t.column :payee_name
          t.column :scheduled_by_user_name
        end

        s.view "REPORT_USER" do |t|
          t.column :reportuser_id
          t.column :name
          t.column :password
          t.column :external_id
          t.column :user_type
          t.column :email_address
          t.column :pdf_export_type
          t.column :default_report_id
        end
  
      end
    end
  end
end
  
