procedure get_token
  ( p_code          in     varchar2
  , po_access_token    out varchar2
  , po_token_type      out varchar2
  , po_expires_in      out number
  , po_id_token        out varchar2
  , po_error           out varchar2
  )
is
  t_response    s4sa_oauth_pck.response_type;
  t_json        json;
begin
    
  t_response := do_request
                  ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'www.linkedin.com/uas/oauth2/accessToken'
                  , p_method  => s4sa_oauth_pck.g_http_method_post_form
                  , p_body    => 'code='          || p_code                   || '&'
                              || 'client_id='     || g_provider.client_id     || '&'
                              || 'client_secret=' || g_provider.client_secret || '&'
                              || 'redirect_uri='  || g_provider.redirect_uri  || '&'
                              || 'grant_type='    || 'authorization_code'     || ''
                   );
    
  if nullif (length (t_response), 0) is not null then
    t_json := json(t_response);
  else
    raise_application_error(-20000, 'No response received.');
  end if;
  
  if t_json.exist('error') then
    po_error := json_ext.get_string(t_json, 'error.message');
  else
    po_error        := null;
    po_access_token := json_ext.get_string(t_json, 'access_token');
    po_expires_in   := json_ext.get_number(t_json, 'expires_in'  );
    po_id_token     := json_ext.get_string(t_json, 'id_token'    );
    po_token_type   := json_ext.get_string(t_json, 'token_type'  );      
  end if;

end get_token;