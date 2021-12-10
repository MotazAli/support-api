create table dbo.users
(
    id           varchar(400) not null
        constraint users_pk
            primary key,
    name         varchar(400),
    inserted_at  timestamp,
    updated_at   timestamp,
    mobile       varchar(100),
    email        varchar(400),
    password     varchar(400),
    country_id   bigint,
    city_id      bigint,
    image        varchar(400),
    address      varchar(400),
    reference_id varchar(400),
    gender       varchar(400)
);



create table dbo.sessions
(
    id          varchar(400) not null
        constraint sessions_pk
            primary key,
    user_id     varchar(400)
        constraint sessions_users_id_fk
            references dbo.users,
    token       text,
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.status_types
(
    id          integer not null
        constraint status_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar(400),
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.user_status
(
    id             varchar(400) not null
        constraint user_status_pk
            primary key,
    status_type_id integer
        constraint user_status_status_types_id_fk
            references dbo.status_types,
    user_id        varchar(400)
        constraint user_status_users_id_fk
            references dbo.users,
    inserted_at    timestamp,
    updated_at     timestamp
);



create table dbo.working_status_types
(
    id          integer not null
        constraint working_status_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar(400),
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.user_working_state
(
    id                     varchar(400) not null
        constraint user_working_state_pk
            primary key,
    user_id                varchar(400)
        constraint user_working_state_users_id_fk
            references dbo.users,
    working_status_type_id integer
        constraint user_working_state_working_status_types_id_fk
            references dbo.working_status_types,
    inserted_at            timestamp,
    updated_at             timestamp
);



create table dbo.client_types
(
    id          integer not null
        constraint client_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar(400),
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.clients
(
    id             varchar(400) not null
        constraint clients_pk
            primary key,
    reference_id   varchar(400),
    client_type_id integer
        constraint clients_client_types_id_fk
            references dbo.client_types,
    name           varchar(400),
    inserted_at    timestamp,
    updated_at     timestamp
);



create table dbo.ticket_types
(
    id          integer not null
        constraint ticket_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar,
    inserted_at timestamp,
    updated_at  timestamp
);

alter table ticket_types
    owner to doadmin;

create table dbo.ticket_status_types
(
    id          integer not null
        constraint ticket_status_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar(400),
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.tickets
(
    id                    varchar(400) not null
        constraint tickets_pk
            primary key,
    ticket_type_id        integer
        constraint tickets_ticket_types_id_fk
            references dbo.ticket_types,
    ticket_status_type_id integer
        constraint tickets_ticket_status_types_id_fk
            references dbo.ticket_status_types,
    description           varchar(400),
    client_id             varchar(400)
        constraint tickets_clients_id_fk
            references dbo.clients,
    inserted_at           timestamp,
    updated_at            timestamp
);



create table dbo.ticket_assigns
(
    id                    varchar(400) not null
        constraint ticket_assigns_pk
            primary key,
    ticket_id             varchar(400),
    user_id               varchar(400)
        constraint ticket_assigns_users_id_fk
            references dbo.users,
    ticket_status_type_id integer
        constraint ticket_assigns_ticket_status_types_id_fk
            references dbo.ticket_status_types,
    inserted_at           timestamp,
    updated_at            timestamp
);



create table dbo.message_types
(
    id          integer not null
        constraint message_types_pk
            primary key,
    type        varchar(400),
    arabic_type varchar(400),
    inserted_at timestamp,
    updated_at  timestamp
);



create table dbo.messages
(
    id              varchar(400) not null
        constraint messages_pk
            primary key,
    ticket_id       varchar(400)
        constraint messages_tickets_id_fk
            references dbo.tickets,
    message_type_id integer
        constraint messages_message_types_id_fk
            references dbo.message_types,
    text            varchar(400),
    is_client       boolean,
    inserted_at     timestamp,
    updated_at      timestamp
);



create table dbo.admins
(
    id           varchar(400) not null
        constraint admins_pkey
            primary key,
    name         varchar(400),
    reference_id varchar(400),
    token        text,
    inserted_at  timestamp,
    updated_at   timestamp,
    email        varchar(400),
    password     varchar(400),
    mobile       varchar(400)
);



