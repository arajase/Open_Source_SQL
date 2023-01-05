CREATE OR REPLACE PACKAGE BODY  "S4SL_AUTH_PCK" is

function do_request
  ( p_api_uri in varchar2
  , p_method  in varchar2 -- POST or GET
  , p_token   in varchar2 default null
  , p_body    in clob     default null
  ) return clob
is
  t_method           varchar2(255);
  l_retval           nclob;
  l_token            varchar2(2000) := p_token;
  CrLf      constant varchar2(2)    := chr(10) || chr(13);
  t_request_headers  s4sa_requests.request_headers%type;
  l_api_uri          varchar2(1000) := p_api_uri;
begin
    
  -- get token from apex if not provided
  if l_token is null then
    l_token := s4sa_oauth_pck.oauth_token('LINKEDIN');
  end if;
  
  -- Linkedin doesn't accept header Bearer + token instead we must make sure the token
  -- is in the url using the oauth2_access_token parameter
  if instr(lower(l_api_uri), 'oauth2_access_token') = 0 then
    -- we must add the parameter
    if instr(l_api_uri, '?') > 0 then
      l_api_uri := l_api_uri || '&oauth2_access_token=' || l_token;
    else
      l_api_uri := l_api_uri || '?oauth2_access_token=' || l_token;
    end if;
  end if;
  
  -- reset headers from previous request
  apex_web_service.g_request_headers.delete;
  utl_http.set_body_charset('UTF-8');
    
  case p_method
    -- POST-FORM
    when s4sa_oauth_pck.g_http_method_post_form then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/x-www-form-urlencoded; charset=UTF-8';
    -- POST-JSON
    when s4sa_oauth_pck.g_http_method_post_json then
      t_method := 'POST';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      --apex_web_service.g_request_headers(2).name  := 'Authorization';
      --apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- GET
    when s4sa_oauth_pck.g_http_method_get then
      t_method := 'GET';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT
    when s4sa_oauth_pck.g_http_method_put then
      t_method := 'PUT';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    -- PUT-JSON
    when s4sa_oauth_pck.g_http_method_put_json then
      t_method := 'PUT';
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json; charset=UTF-8';
      --apex_web_service.g_request_headers(2).name  := 'Authorization';
      --apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
    -- DELETE
    when s4sa_oauth_pck.g_http_method_delete then
      t_method := 'DELETE';
      --apex_web_service.g_request_headers(1).name  := 'Authorization';
      --apex_web_service.g_request_headers(1).value := 'Bearer ' || l_token;
    else
      raise s4sa_oauth_pck.e_parameter_check;
  end case;
    
  l_retval := apex_web_service.make_rest_request
                ( p_url         => l_api_uri
                , p_http_method => t_method
                , p_wallet_path => s4sa_oauth_pck.g_settings.wallet_path
                , p_wallet_pwd  => s4sa_oauth_pck.g_settings.wallet_pwd
                , p_body        => p_body
                );
                  
  begin
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'LINKEDIN'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
  end;
    
  apex_web_service.g_request_headers.delete;
    
  return l_retval;

exception
  when others then
    for ii in 1..apex_web_service.g_request_headers.count loop
      t_request_headers := t_request_headers 
                        || rpad(apex_web_service.g_request_headers(ii).name, 30) || ' = ' 
                        || apex_web_service.g_request_headers(ii).value || CrLf;
    end loop;
    s4sa_oauth_pck.store_request
      ( p_provider        => 'LINKEDIN'
      , p_request_uri     => l_api_uri
      , p_request_type    => t_method || ' (' || p_method || ')'
      , p_request_headers => t_request_headers
      , p_body            => p_body
      , p_response        => l_retval );
    raise;
end do_request;