###
###               ejabberd configuration file
###
###

### The parameters used in this configuration file are explained in more detail
### in the ejabberd Installation and Operation Guide.
### Please consult the Guide in case of doubts, it is included with
### your copy of ejabberd, and is also available online at
### http://www.process-one.net/en/ejabberd/docs/

###   =======
###   LOGGING

loglevel: {{ env['EJABBERD_LOGLEVEL'] or 4 }}
log_rotate_size: 10485760
log_rotate_count: 0

## watchdog_admins:
##   - "bob@example.com"

###   ================
###   SERVED HOSTNAMES

hosts:
{%- for xmpp_domain in env['XMPP_DOMAIN'].split() %}
  - "{{ xmpp_domain }}"
{%- endfor %}

##
## route_subdomains: Delegate subdomains to other XMPP servers.
## For example, if this ejabberd serves example.org and you want
## to allow communication with an XMPP server called im.example.org.
##
## route_subdomains: s2s

###   ===============
###   LISTENING PORTS

listen:
  -
    port: 5222
    module: ejabberd_c2s
    {%- if env['EJABBERD_STARTTLS'] == "true" %}
    starttls_required: true
    {%- endif %}
    protocol_options:
      - "no_sslv2"
      - "no_sslv3"
    {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1', "false") == "false" %}
      - "no_tlsv1"
    {%- endif %}
    {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1_1', "true") == "false" %}
      - "no_tlsv1_1"
    {%- endif %}
      - "cipher_server_preference"
    max_stanza_size: 65536
    shaper: c2s_shaper
    access: c2s
    tls_compression: false
    ciphers: "{{ env.get('EJABBERD_CIPHERS', 'HIGH:!aNULL:!3DES') }}"
    {%- if env.get('EJABBERD_DHPARAM', false) == "true" %}
    dhfile: "/opt/ejabberd/ssl/dh.dhpem"
    {%- endif %}
  -
    port: 5223
    module: ejabberd_c2s
    {%- if env['EJABBERD_STARTTLS'] == "true" %}
    tls: true
    {%- endif %}
    protocol_options:
      - "no_sslv2"
      - "no_sslv3"
    {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1', "false") == "false" %}
      - "no_tlsv1"
    {%- endif %}
    {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1_1', "false") == "false" %}
      - "no_tlsv1_1"
    {%- endif %}
      - "cipher_server_preference"
    max_stanza_size: 65536
    shaper: c2s_shaper
    access: c2s
    tls_compression: false
    ciphers: "{{ env.get('EJABBERD_CIPHERS', 'HIGH:!aNULL:!3DES') }}"
    {%- if env.get('EJABBERD_DHPARAM', false) == "true" %}
    dhfile: "/opt/ejabberd/ssl/dh.dhpem"
    {%- endif %}
  -
    port: 5269
    module: ejabberd_s2s_in
    {%- if env['EJABBERD_S2S_SSL'] == "true" %}
  -
    port: 5270
    module: ejabberd_s2s_in
    tls: true
    {% endif %}
  -
    port: 4560
    module: ejabberd_xmlrpc
    #api_permissions:
    #  configure:
    #    all: []


  -
    port: 5280
    module: ejabberd_http
    request_handlers:
      "/websocket": ejabberd_http_ws
    ##  "/pub/archive": mod_http_fileserver
    web_admin: true
    http_bind: true
    ## register: true
    {%- if env.get('EJABBERD_CAPTCHA', false) == "true" %}
    captcha: true
    {% endif %}
    {%- if env['EJABBERD_HTTPS'] == "true" %}
    tls: true
    tls_compression: false
    ciphers: "{{ env.get('EJABBERD_CIPHERS', 'HIGH:!aNULL:!3DES') }}"
    {%- if env.get('EJABBERD_DHPARAM', "false") == "true" %}
    dhfile: "/opt/ejabberd/ssl/dh.dhpem"
    {%- endif %}
    {% endif %}
  -
{%- if env.get('EJABBERD_STUN', "false") == "true" %}
    port: 3478
    module: ejabberd_stun
    auth_realm: "{{ env['XMPP_DOMAIN'] }}"
    {%- if env.get('EJABBERD_TURN_IP') %}
    use_turn: true
    ## The server's public IPv4 address:
    turn_ipv4_address: {{ env.get('EJABBERD_TURN_IP') }}
    {%- endif %}
  -
    port: 3478
    transport: udp
    module: ejabberd_stun
    auth_realm: "{{ env['XMPP_DOMAIN'] }}"
    {%- if env.get('EJABBERD_TURN_IP') %}
    use_turn: true
    ## The server's public IPv4 address:
    turn_ipv4_address: {{ env.get('EJABBERD_TURN_IP') }}
    {%- endif %}
  -
    port: 5349
    transport: tcp
    module: ejabberd_stun
    tls: true
    auth_realm: "{{ env['XMPP_DOMAIN'] }}"
    {%- if env.get('EJABBERD_TURN_IP') %}
    use_turn: true
    ## The server's public IPv4 address:
    turn_ipv4_address: {{ env.get('EJABBERD_TURN_IP') }}
    {%- endif %}
  -
{%- endif %}
    port: 5443
    module: ejabberd_http
    request_handlers:
      "": mod_http_upload
    {%- if env['EJABBERD_HTTPS'] == "true" %}
    tls: true
    tls_compression: false
    ciphers: "{{ env.get('EJABBERD_CIPHERS', 'HIGH:!aNULL:!3DES') }}"
    {%- if env.get('EJABBERD_DHPARAM', false) == "true" %}
    dhfile: "/opt/ejabberd/ssl/dh.dhpem"
    {%- endif %}
    {% endif %}


###   CERTIFICATES
###   ================
certfiles:
  - "/opt/ejabberd/ssl/*.pem"

###   SERVER TO SERVER
###   ================

{%- if env['EJABBERD_S2S_SSL'] == "true" %}
s2s_use_starttls: required
s2s_protocol_options:
  - "no_sslv2"
  - "no_sslv3"
  {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1', "false") == "false" %}
  - "no_tlsv1"
  {%- endif %}
  {%- if env.get('EJABBERD_PROTOCOL_OPTIONS_TLSV1_1', "true") == "false" %}
  - "no_tlsv1_1"
  {%- endif %}
  - "cipher_server_preference"
s2s_ciphers: "{{ env.get('EJABBERD_CIPHERS', 'HIGH:!aNULL:!3DES') }}"
{%- if env.get('EJABBERD_DHPARAM', false) == "true" %}
s2s_dhfile: "/opt/ejabberd/ssl/dh.dhpem"
{%- endif %}
{% endif %}

###   ==============
###   AUTHENTICATION

auth_method:
{%- for auth_method in env.get('EJABBERD_AUTH_METHOD', 'internal').split() %}
  - {{ auth_method }}
{%- endfor %}

auth_password_format: {{ env.get('EJABBERD_AUTH_PASSWORD_FORMAT', 'scram') }}

{%- if 'anonymous' in env.get('EJABBERD_AUTH_METHOD', 'internal').split() %}
anonymous_protocol: both
allow_multiple_connections: true
{%- endif %}


## LDAP authentication

{%- if 'ldap' in env.get('EJABBERD_AUTH_METHOD', 'internal').split() %}

ldap_servers:
{%- for ldap_server in env.get('EJABBERD_LDAP_SERVERS', 'internal').split() %}
  - "{{ ldap_server }}"
{%- endfor %}

ldap_encrypt: {{ env.get('EJABBERD_LDAP_ENCRYPT', 'none') }}
ldap_tls_verify: {{ env.get('EJABBERD_LDAP_TLS_VERIFY', 'false') }}

{%- if env['EJABBERD_LDAP_TLS_CACERTFILE'] %}
ldap_tls_cacertfile: "{{ env['EJABBERD_LDAP_TLS_CACERTFILE'] }}"
{%- endif %}

ldap_tls_depth: {{ env.get('EJABBERD_LDAP_TLS_DEPTH', 1) }}

{%- if env['EJABBERD_LDAP_PORT'] %}
ldap_port: {{ env['EJABBERD_LDAP_PORT'] }}
{%- endif %}

{%- if env['EJABBERD_LDAP_ROOTDN'] %}
ldap_rootdn: "{{ env['EJABBERD_LDAP_ROOTDN'] }}"
{%- endif %}

{%- if env['EJABBERD_LDAP_PASSWORD'] %}
ldap_password: "{{ env['EJABBERD_LDAP_PASSWORD'] }}"
{%- endif %}

ldap_deref_aliases: {{ env.get('EJABBERD_LDAP_DEREF_ALIASES', 'never') }}
ldap_base: "{{ env['EJABBERD_LDAP_BASE'] }}"

{%- if env['EJABBERD_LDAP_UIDS'] %}
ldap_uids:
{%- for ldap_uid in env['EJABBERD_LDAP_UIDS'].split() %}
  "{{ ldap_uid.split(':')[0] }}": "{{ ldap_uid.split(':')[1] }}"
{%- endfor %}
{%- endif %}

{%- if env['EJABBERD_LDAP_FILTER'] %}
ldap_filter: "{{ env['EJABBERD_LDAP_FILTER'] }}"
{%- endif %}

{%- if env['EJABBERD_LDAP_DN_FILTER'] %}
ldap_dn_filter:
{%- for dn_filter in env['EJABBERD_LDAP_DN_FILTER'].split() %}
  "{{ dn_filter.split(':')[0] }}": ["{{ dn_filter.split(':')[1] }}"]
{%- endfor %}
{%- endif %}

{%- endif %}

{%- if 'external' in env.get('EJABBERD_AUTH_METHOD', 'internal').split() %}
  {%- if env['EJABBERD_EXTAUTH_PROGRAM'] %}
extauth_program: "{{ env['EJABBERD_EXTAUTH_PROGRAM'] }}"
  {%- endif %}
  {%- if env['EJABBERD_EXTAUTH_INSTANCES'] %}
extauth_instances: {{ env['EJABBERD_EXTAUTH_INSTANCES'] }}
  {%- endif %}
  {%- if 'internal' in env.get('EJABBERD_AUTH_METHOD').split() %}
extauth_cache: false
  {%- elif env['EJABBERD_EXTAUTH_CACHE'] %}
extauth_cache: {{ env['EJABBERD_EXTAUTH_CACHE'] }}
  {%- endif %}
{% endif %}

###   ===============
###   TRAFFIC SHAPERS

shaper:
  normal:
    rate: 10000
    burst_size: 30000
  fast: 100000

###   ====================
###   ACCESS CONTROL LISTS

acl:
  admin:
    user:
    {%- if env['EJABBERD_ADMINS'] %}
      {%- for admin in env['EJABBERD_ADMINS'].split() %}
      - "{{ admin.split('@')[0] }}": "{{ admin.split('@')[1] }}"
      {%- endfor %}
    {%- else %}
      - "admin": "{{ env['XMPP_DOMAIN'].split()[0] }}"
    {%- endif %}
  local:
    user_regexp: ""

###   ============
###   ACCESS RULES

access_rules:
  ## This rule allows access only for local users:
  local:
    allow: local
  ## Only non-blocked users can use c2s connections:
  c2s:
    deny: blocked 
    allow: all 
  ## Only admins can send announcement messages:
  announce:
    allow: admin
  ## Only admins can use the configuration interface:
  configure:
    allow: admin
  ## Admins of this server are also admins of the MUC service:
  muc_admin:
    allow: admin
  ## Only accounts of the local ejabberd server, or only admins can create rooms, depending on environment variable:
  muc_create:
    {%- if env['EJABBERD_MUC_CREATE_ADMIN_ONLY'] == "true" %}
    allow: admin 
    {% else %}
    allow: local
    {% endif %}
  ## All users are allowed to use the MUC service:
  muc:
    allow: all 
  ## Only accounts on the local ejabberd server can create Pubsub nodes:
  pubsub_createnode:
    allow: local
  ## In-band registration allows registration of any possible username.
  register:
    {%- if env['EJABBERD_REGISTER_ADMIN_ONLY'] == "true" %}
    deny: all
    allow: admin
    {% else %}
    deny: all
    {% endif %}
  ## Only allow to register from localhost
  trusted_network:
    allow: loopback

###   ============
###   SHAPER RULES

shaper_rules:
  ## Maximum number of simultaneous sessions allowed for a single user:
  max_user_sessions: 10
  ## Maximum number of offline messages that users can have:
  max_user_offline_messages:
    5000 : admin 
    100 : all
  ## For C2S connections, all users except admins use the "normal" shaper
  c2s_shaper:
    none: admin
    normal: all
  ## All S2S connections use the "fast" shaper
  s2s_shaper: fast
  soft_upload_quota:
    - {{ env.get('EJABBERD_SOFT_UPLOAD_QUOTA', 400) }} : all # MiB
  hard_upload_quota:
    - {{ env.get('EJABBERD_HARD_UPLOAD_QUOTA', 500) }} : all # MiB

language: "en"

###   =======
###   MODULES

modules:
  mod_adhoc: {}
  {% if env.get('EJABBERD_MOD_ADMIN_EXTRA', "true") == "true" %}
  mod_admin_extra: {}
  {% endif %}
  mod_announce: # recommends mod_adhoc
    access: announce
  mod_blocking: {} # requires mod_privacy
  mod_bosh: {}
  mod_caps: {}
  mod_carboncopy: {}
  mod_client_state:
    queue_chat_states: true
    queue_presence: false
  mod_configure: {} # requires mod_adhoc
  mod_disco: {}
  ## mod_echo: {}
  ## mod_http_fileserver:
  ##   docroot: "/var/www"
  ##   accesslog: "/var/log/ejabberd/access.log"
  mod_http_upload:
    docroot: "/opt/ejabberd/upload"
    {%- if env['EJABBERD_HTTPS'] == "true" %}
    put_url: "https://@HOST@:5443"
    {%- else %}
    put_url: "http://@HOST@:5443"
    {% endif %}
  mod_http_upload_quota:
    max_days: {{ env.get('EJABBERD_UPLOAD_QUOTA_MAX_DAYS', 10) }}
  mod_last: {}
  mod_mam:
    default: always
    use_cache: true
    compress_xml: true
  mod_muc:
    host: "conference.@HOST@"
    access: muc
    access_create: muc_create
    access_persistent: muc_create
    access_admin: muc_admin
    history_size: 500
    default_room_options:
      persistent: true
      mam : true
  {%- if env['EJABBERD_MOD_MUC_ADMIN'] == "true" %}
  mod_muc_admin: {}
  {% endif %}
  ## mod_muc_log: {}
  ## mod_multicast: {}
  mod_offline:
    access_max_user_messages: max_user_offline_messages
  mod_ping: {}
  ## mod_pres_counter:
  ##   count: 5
  ##   interval: 60
  mod_privacy: {}
  mod_private: {}
  mod_proxy65:
    host: "proxy.@HOST@"
    name: "File Transfer Proxy"
    port: 5277
  mod_pubsub:
    access_createnode: pubsub_createnode
    force_node_config:
      "eu.siacs.conversations.axolotl.*":
        access_model: open
    ## reduces resource comsumption, but XEP incompliant
    # ignore_pep_from_offline: true
    ## XEP compliant, but increases resource comsumption
    ignore_pep_from_offline: false
    last_item_cache: true
    plugins:
      - "flat"
      - "pep" # pep requires mod_caps
  mod_push: {}
  mod_push_keepalive: {}
  mod_register:
    {%- if env.get('EJABBERD_CAPTCHA', false) == "true" %}
    ##
    ## Protect In-Band account registrations with CAPTCHA.
    ##
    captcha_protected: true
    {% endif %}

    ##
    ## Set the minimum informational entropy for passwords.
    ##
    ## password_strength: 32

    ##
    ## After successful registration, the user receives
    ## a message with this subject and body.
    ##
    welcome_message:
      subject: "Welcome!"
      body: |-
        Hi.
        Welcome to this XMPP server.

    ##
    ## Only clients in the server machine can register accounts
    ##
    {%- if env.get('EJABBERD_REGISTER_TRUSTED_NETWORK_ONLY', "true") == "true" %}
    ip_access: trusted_network
    {% endif %}

    access: register
  mod_roster:
    versioning: true
  mod_s2s_dialback: {}
  mod_shared_roster: {}
  mod_stats: {}
  mod_stream_mgmt:
    resend_on_timeout: if_offline
{%- if env.get('EJABBERD_STUN', "false") == "true" %}
  mod_stun_disco:
    secret: "{{ env.get('EJABBERD_STUN_DISCO_SECRET', 'it-is-secret') }}"
    services:
      -
        host: {{ env.get('EJABBERD_TURN_IP') }} # Your coturn's public address.
        port: 3478
        type: stun
        transport: udp
        restricted: false
      -
        host: {{ env.get('EJABBERD_TURN_IP') }} # Your coturn's public address.
        port: 3478
        type: turn
        transport: udp
        restricted: true
      -
        host: stun.@HOST@ # Your coturn's public address.
        port: 5349
        type: stuns
        transport: tcp
        restricted: false
      -
        host: turn.@HOST@ # Your coturn's public address.
        port: 5349
        type: turns
        transport: tcp
        restricted: true
{%- endif %}
  mod_time: {}
  #mod_avatar: {}
  mod_vcard: {}
  {%- if env.get('EJABBERD_MOD_VERSION', "true") == "true" %}
  mod_version:
    show_os: false
  {%- endif %}

###   ============
###   HOST CONFIG

{%- if env['EJABBERD_CONFIGURE_ODBC'] == "true" %}
###   ====================
###   ODBC DATABASE CONFIG
sql_type: {{ env['EJABBERD_ODBC_TYPE'] }}
sql_server: "{{ env['EJABBERD_ODBC_SERVER'] }}"
sql_database: "{{ env['EJABBERD_ODBC_DATABASE'] }}"
sql_username: "{{ env['EJABBERD_ODBC_USERNAME'] }}"
sql_password: "{{ env['EJABBERD_ODBC_PASSWORD'] }}"
sql_keepalive_interval: "{{ env.get('EJABBERD_ODBC_KEEPALIVE_INTERVAL', 60) }}"

default_db: sql
{% endif %}

{%- if env['EJABBERD_DEFAULT_DB'] is defined %}
default_db: {{ env['EJABBERD_DEFAULT_DB'] }}
{% endif %}

###   =====================
###   SESSION MANAGEMENT DB
sm_db_type: {{ env['EJABBERD_SESSION_DB'] or "mnesia" }}

{%- if env['EJABBERD_CONFIGURE_REDIS'] == "true" %}
###   ====================
###   REDIS DATABASE CONFIG
redis_server: {{ env['EJABBERD_REDIS_SERVER'] or "localhost" }}
redis_port: {{ env['EJABBERD_REDIS_PORT'] or 6379 }}
{%- if env['EJABBERD_REDIS_PASSWORD'] is defined %}
redis_password: {{ env['EJABBERD_REDIS_PASSWORD'] }}
{% endif %}
redis_db: {{ env['EJABBERD_REDIS_DB'] or 0}}
redis_reconnect_timeout: {{ env['EJABBERD_REDIS_RECONNECT_TIMEOUT'] or 1 }}
redis_connect_timeout: {{ env['EJABBERD_REDIS_CONNECT_TIMEOUT'] or 1 }}
{% endif %}

{%- if env.get('EJABBERD_CAPTCHA', false) == "true" %}
###   =======
###   CAPTCHA
##
## Full path to a script that generates the image.
captcha_cmd: "{{ env.get('EJABBERD_CAPTCHA_CMD', '/usr/local/lib/ejabberd-' ~ env['EJABBERD_BRANCH'] ~ '/priv/bin/captcha.sh') }}"
{% endif %}
