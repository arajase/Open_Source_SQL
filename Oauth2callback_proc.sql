procedure oauth2callback
  ( state             in varchar2 default null
  , code              in varchar2 default null
  , error             in varchar2 default null
  , error_description in varchar2 default null
  , token             in varchar2 default null
  )
  is
    t_querystring   wwv_flow_global.vc_arr2;
    t_session       varchar2(255);
    t_workspaceid   varchar2(255);
    t_appid         varchar2(255);
    t_gotopage      varchar2(255);
    t_code          varchar2(32767) := code;
    t_access_token  varchar2(32767);
    t_token_type    varchar2(255);
    t_expires_in    varchar2(255);
    t_id_token      varchar2(32767);
    t_error         varchar2(32767);
    t_oauth_user    s4sa_oauth_pck.oauth2_user;
  begin
    
    if error is not null then
      raise_application_error(-20000, error_description);
    end if;
    
    t_querystring := apex_util.string_to_table(state, ':');
    
    for ii in 1..t_querystring.count loop
      case ii
        when 1 then t_session     := t_querystring(ii);
        when 2 then t_workspaceid := t_querystring(ii);
        when 3 then t_appid       := t_querystring(ii);
        when 4 then t_gotopage    := t_querystring(ii);   
        else null;
      end case;
    end loop;
    
    get_token( p_code          => t_code
             , po_access_token => t_access_token
             , po_token_type   => t_token_type
             , po_expires_in   => t_expires_in
             , po_id_token     => t_id_token
             , po_error        => t_error
             );
      
    t_oauth_user := get_user(p_token => t_access_token);
             
    if t_error is null then
      
       s4sa_oauth_pck.do_oauth_login
       ( p_provider     => 'LINKEDIN'
       , p_session      => t_session
       , p_workspaceid  => t_workspaceid
       , p_appid        => t_appid
       , p_gotopage     => t_gotopage
       , p_code         => t_code
       , p_access_token => t_access_token
       , p_token_type   => t_token_type
       , p_expires_in   => t_expires_in
       , p_id_token     => t_id_token
       , p_error        => t_error
       , p_oauth_user   => t_oauth_user
       );
      
    else
      
      owa_util.redirect_url(v('LOGIN_URL') || '&notification_msg=' || apex_util.url_encode(t_error));  
    
    end if;
    
  end oauth2callback;