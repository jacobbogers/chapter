create table users
(
  id uuid primary key,
  first_name text not null ,
  last_name text,
  email text not null,
  password_digest text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table social_providers
(
  id uuid primary key,
  name text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table social_provider_users
(
  id uuid primary key,
  provider_id uuid references social_providers(id) not null,
  provider_user_id text not null,
  user_id uuid references users(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table locations (
  id uuid primary key,
  country_code char(2) not null,
  city text not null,
  region text,
  postal_code text,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table chapters
(
  id uuid primary key ,
  name text unique not null,
  description text not null,
  category text not null,
  details jsonb,
  location_id uuid references locations(id) not null,
  creator_id uuid references users(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table venues
(
  id uuid primary key,
  name text not null,
  location_id uuid references locations(id) not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create type sponsor_type as enum
('FOOD', 'VENUE', 'OTHER');

create table sponsors
(
  id uuid primary key,
  name text not null,
  website text,
  logo_path text,
  type sponsor_type not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table tags
(
  id uuid primary key,
  name text not null
);

create table events
(
  id uuid primary key,
  name text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  chapter_id uuid references chapters(id) not null ,
  venue_id uuid references venues(id),
  tag_id uuid references tags(id),
  canceled boolean default false,
  capacity int not null,
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table event_sponsors
(
  event_id uuid references events(id),
  sponsor_id uuid references sponsors(id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table user_chapters
(
  user_id uuid references users(id),
  chapter_id uuid references chapters(id),
  primary key(user_id, chapter_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table rsvps
(
  user_id uuid references  users(id),
  event_id uuid references events(id),
  date timestamptz not null,
  on_waitlist boolean not null default FALSE,
  primary key(user_id, event_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table user_bans
(
  user_id uuid references users(id),
  chapter_id uuid references chapters(id),
  primary key(user_id, chapter_id),
  created_at timestamp default CURRENT_TIMESTAMP,
  updated_at timestamp default CURRENT_TIMESTAMP
);

create table chapter_emails_endpoints
(
    chapter_id uuid references chapters(id),
    email_contact text not null,
    primary key(chapter_id, email_contact),
    contact_descr text not null, -- description for admin config panel 
    created_at timestamp default CURRENT_TIMESTAMP,
    updated_at timestamp default CURRENT_TIMESTAMP 
);


-- outgoing emails created per chapter
create table emails
(
   id uuid,
   chapter_id uuid references chapters(id),
   email_sender text, -- address to display as sender 
   email_reply_to text, -- address to put in the reply too field
   primary key(id),
   FOREIGN KEY (chapter_id, email_sender) REFERENCES chapter_emails_endpoints(chapter_id, email_contact),
   FOREIGN KEY (chapter_id, email_reply_to) REFERENCES chapter_emails_endpoints(chapter_id, email_contact),
   subject text not NULL,
   body_text text NOT NULL, -- plaintext
   body_html text, -- html variant of the body_text
   watchHTML text, -- html specific for apple watch
   amp text -- message confirming to amp standard
);

create table email_user_sent
(
   message_id text, -- message id returned from node_mailer unqiuely identifying a singular email sent
   email_message_id uuid,
   user_id uuid, -- the user this email was sent
   primary key(message_id),
   foreign key (email_message_id) REFERENCES emails(id),
   foreign key (user_id) REFERENCES users(id),
   status text, -- email status, successfully posted, received, bounced, whatever 
   created_at timestamp default CURRENT_TIMESTAMP,
   updated_at timestamp default CURRENT_TIMESTAMP 
)


-- smtp configuration is stored in the DB and can be changed via an admin console
-- nodemailer transport plugin are very specific to the transport, so they will need their own specific configuration
--
create table config_smtp (
    port integer not null,
    host text not null,
    auth_type text, -- : string (in this case only support 'login') enum ('OAuth2', )
    auth_user text, -- : string
    auth_pass text -- : normal,
    secure boolean default false,
    -- tls no tls object
    tls_servername text,
    tls_ignoreTLS  boolean,
    tls_requireTLS boolean,
    tls_rejectUnauthorized boolean,  -- // do not fail on invalid certificates
    
    name text,
    localAddress text
    connectionTimeout integer,
    greetingTimeout integer,
    socketTimeout integer,
    disableFileAccess boolean default TRUE,
    disableUrlAccess boolean default TRUE
)

