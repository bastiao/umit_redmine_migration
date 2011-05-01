


class IssuesGatewayController < ApplicationController
      
    
    def create
                

        summary = params["field_summary"]
        description = params["field_type"]
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


        # mapamento de parametros do trac para redmine? como fazr?


   call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })

    if @issue.save
      attachments = Attachment.attach_files(@issue, params[:attachments])
      render_attachment_warning_if_needed(@issue)
      flash[:notice] = l(:notice_successful_create)
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          redirect_to(params[:continue] ?  { :action => 'new', :project_id => @project, :issue => {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?} } :
                      { :action => 'show', :id => @issue })
        }
        format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@issue) }
      end
    end

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




