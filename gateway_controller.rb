# Author: Luis A. Bastião Silva



require 'iconv'

class GatewayController < ApplicationController
   
skip_before_filter :verify_authenticity_token
        TICKET_MAP = []

      def encode(text)
        @ic.iconv text
      rescue
        text
      end
      # Basic wiki syntax conversion
      def convert_wiki_text(text)
        # Titles
        text = text.gsub(/^(\=+)\s(.+)\s(\=+)/) {|s| "\nh#{$1.length}. #{$2}\n"}
        # External Links
        text = text.gsub(/\[(http[^\s]+)\s+([^\]]+)\]/) {|s| "\"#{$2}\":#{$1}"}
        # Ticket links:
        #      [ticket:234 Text],[ticket:234 This is a test]
        text = text.gsub(/\[ticket\:([^\ ]+)\ (.+?)\]/, '"\2":/issues/show/\1')
        #      ticket:1234
        #      #1 is working cause Redmine uses the same syntax.
        text = text.gsub(/ticket\:([^\ ]+)/, '#\1')
        # Milestone links:
        #      [milestone:"0.1.0 Mercury" Milestone 0.1.0 (Mercury)]
        #      The text "Milestone 0.1.0 (Mercury)" is not converted,
        #      cause Redmine's wiki does not support this.
        text = text.gsub(/\[milestone\:\"([^\"]+)\"\ (.+?)\]/, 'version:"\1"')
        #      [milestone:"0.1.0 Mercury"]
        text = text.gsub(/\[milestone\:\"([^\"]+)\"\]/, 'version:"\1"')
        text = text.gsub(/milestone\:\"([^\"]+)\"/, 'version:"\1"')
        #      milestone:0.1.0
        text = text.gsub(/\[milestone\:([^\ ]+)\]/, 'version:\1')
        text = text.gsub(/milestone\:([^\ ]+)/, 'version:\1')
        # Internal Links
        text = text.gsub(/\[\[BR\]\]/, "\n") # This has to go before the rules below
        text = text.gsub(/\[\"(.+)\".*\]/) {|s| "[[#{$1.delete(',./?;|:')}]]"}
        text = text.gsub(/\[wiki:\"(.+)\".*\]/) {|s| "[[#{$1.delete(',./?;|:')}]]"}
        text = text.gsub(/\[wiki:\"(.+)\".*\]/) {|s| "[[#{$1.delete(',./?;|:')}]]"}
        text = text.gsub(/\[wiki:([^\s\]]+)\]/) {|s| "[[#{$1.delete(',./?;|:')}]]"}
        text = text.gsub(/\[wiki:([^\s\]]+)\s(.*)\]/) {|s| "[[#{$1.delete(',./?;|:')}|#{$2.delete(',./?;|:')}]]"}

  # Links to pages UsingJustWikiCaps
  text = text.gsub(/([^!]|^)(^| )([A-Z][a-z]+[A-Z][a-zA-Z]+)/, '\\1\\2[[\3]]')
  # Normalize things that were supposed to not be links
  # like !NotALink
  text = text.gsub(/(^| )!([A-Z][A-Za-z]+)/, '\1\2')
        # Revisions links
        text = text.gsub(/\[(\d+)\]/, 'r\1')
        # Ticket number re-writing
        text = text.gsub(/#(\d+)/) do |s|
          if $1.length < 10
#            TICKET_MAP[$1.to_i] ||= $1
            "\##{TICKET_MAP[$1.to_i] || $1}"
          else
            s
          end
        end
        # We would like to convert the Code highlighting too
        # This will go into the next line.
        shebang_line = false
        # Reguar expression for start of code
        pre_re = /\{\{\{/
        # Code hightlighing...
        shebang_re = /^\#\!([a-z]+)/
        # Regular expression for end of code
        pre_end_re = /\}\}\}/

        # Go through the whole text..extract it line by line
        text = text.gsub(/^(.*)$/) do |line|
          m_pre = pre_re.match(line)
          if m_pre
            line = '<pre>'
          else
            m_sl = shebang_re.match(line)
            if m_sl
              shebang_line = true
              line = '<code class="' + m_sl[1] + '">'
            end
            m_pre_end = pre_end_re.match(line)
            if m_pre_end
              line = '</pre>'
              if shebang_line
                line = '</code>' + line
              end
            end
          end
          line
        end

        # Highlighting
        text = text.gsub(/'''''([^\s])/, '_*\1')
        text = text.gsub(/([^\s])'''''/, '\1*_')
        text = text.gsub(/'''/, '*')
        text = text.gsub(/''/, '_')
        text = text.gsub(/__/, '+')
        text = text.gsub(/~~/, '-')
        text = text.gsub(/`/, '@')
        text = text.gsub(/,,/, '~')
        # Lists
        text = text.gsub(/^([ ]+)\* /) {|s| '*' * $1.length + " "}

        text
      end



    def index
	#head :created, :trac_session => "null"
	#head :created, :trac_form_token => "null"
	#render_404
	#return "test"
	cookies[:trac_session] = "nil"
	cookies[:trac_form_token] = "nil"
#    render :layout => false, :content_type => 'text/plain'
      	render :text => "Bug Report - CRASH REPORT"
	
#	render_404
    end


    def create2

           
        summary = params["field_summary"]
	if params

      		render :text => "Bug Report"
	end
    end  

    def create
                
        summary = params["field_summary"]
        type = params["field_type"]
        description = params["field_description"]
        milestore = params["field_milestone"]
        component = params["field_component"]
        version = params["field_component"]
        keywords = params["field_keywords"]
        owner = params["owner"]
        cc = params["cc"]
        author = params["author"]
        attachment = params["attachment"]
        status = params["field_status"]
        action = params["create"]
        submit = params["submit"]
	#render :text => params.to_json
	#render :text => component

	# maping redmine params? trac---> redmine #FIXME - Ruby Lovers!

      	#render :text => component

      @issue = Issue.new
      @issue.copy_from(params[:copy_from]) if params[:copy_from]
      @issue.subject = summary 
      @issue.description = "Reporter: " + author + "\n\n\n" +  convert_wiki_text(encode(description))
      
      
      is_crash_report = component.include? 'CrashReport'
      is_crash_report_pm = component.include? 'PacketManipulator'
      
      if is_crash_report == true
  #   render :text => "crashreport"
      	@issue.project =  Project.find_by_identifier("uns")
      elsif is_crash_report_pm == true
      	@issue.project =  Project.find_by_identifier("pm")
	render :text => "crashreport - pm"
      else
      	render :text => "die bitch"
     end
      

    # Tracker must be set before custom field values
    @issue.tracker = Tracker.find_by_id(1)
    #if @issue.tracker.nil?
    #  render_error l(:error_no_tracker_in_project)
    #  return false
    #end
    @issue.start_date ||= Date.today
    #if params[:issue].is_a?(Hash)
    #  @issue.safe_attributes = params[:issue]
    #  if User.current.allowed_to?(:add_issue_watchers, @project) && @issue.new_record?
    #    @issue.watcher_user_ids = params[:issue]['watcher_user_ids']
    #  end
    #end
    #user_umit = User.find_by_identifier("admin")
    @issue.author = User.find_by_login("crashreport")
    @priorities = IssuePriority.all
    #@allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
if	@issue.save
	
      	render :text => "damm"
else

      	render :text => @issue.errors.full_messages
end
      #@issue.project = @project


     # render :text => "Bug Report"

   #call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })


    #render :text => params.to_json


                #   "field_summary": self.summary,
                #"__FORM_TOKEN": trac_form,
                #"field_type": self.type,
                #"field_description": self.details,
                #"field_milestone": self.milestone,
                #"field_component":self.component,
                #"field_version": self.version,
                #"field_keywords": self.keywords,
                #"owner":self.assigned_to,
                #"cc": self.cc,
                #"author": self.reporter,
                #"attachment":self.input_file,
                #"field_status": "new",
                #"action": "create",
                #"submit": self.submit
                #}     
    end


  # TODO: Refactor, lots of extra code in here
  # TODO: Changing tracker on an existing issue should not trigger this
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      @issue.copy_from(params[:copy_from]) if params[:copy_from]
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end

    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today
    if params[:issue].is_a?(Hash)
      @issue.safe_attributes = params[:issue]
      if User.current.allowed_to?(:add_issue_watchers, @project) && @issue.new_record?
        @issue.watcher_user_ids = params[:issue]['watcher_user_ids']
      end
    end
    user_umit = User.find(:first, "login = 'crashreport' AND password = 'crashreport'")
    @issue.author = user_umit
    @priorities = IssuePriority.all
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
  end




end
