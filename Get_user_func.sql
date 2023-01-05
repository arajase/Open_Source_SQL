function get_user(p_token in varchar2)
  return s4sa_oauth_pck.oauth2_user
  is
    t_response s4sa_oauth_pck.response_type;
    t_retval   s4sa_oauth_pck.oauth2_user;
    t_json     json;
  begin
    
    t_response := do_request
                    ( p_api_uri => s4sa_oauth_pck.g_settings.api_prefix || 'api.linkedin.com/v1/people/~:'
                                || '(id,num-connections,picture-url,email-address,firstName,'
                                || 'lastName,formatted-name,api-standard-profile-request,'
                                || 'public-profile-url)?format=json'
                    , p_method  => 'GET'
                    , p_token   => p_token);
    
    s4sa_oauth_pck.check_for_error( t_response );
    
    t_json := json(t_response);
    
    t_retval.id             := json_ext.get_string(t_json, 'id'               );
    t_retval.email          := json_ext.get_string(t_json, 'emailAddress'     );
    t_retval.verified       := json_ext.get_bool  (t_json, 'verified_email'   );
    t_retval.name           := json_ext.get_string(t_json, 'formattedName'    );
    t_retval.given_name     := json_ext.get_string(t_json, 'firstName'        );
    t_retval.family_name    := json_ext.get_string(t_json, 'lastName'         );
    t_retval.link           := json_ext.get_string(t_json, 'publicProfileUrl' );
    t_retval.picture        := json_ext.get_string(t_json, 'pictureUrl'       );
    --t_retval.gender         := json_ext.get_string(t_json, 'gender'           );
    --t_retval.locale         := json_ext.get_string(t_json, 'locale'           );
    --t_retval.hd             := json_ext.get_string(t_json, 'hd'               );
    
    return t_retval;
    
  end get_user;