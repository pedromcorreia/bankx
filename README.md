# Bankx

This applications supports you to create new bank account, follow your bank account
status, invite other friends and follow indications.

- This app use uuid as id for create a referral_code, this is used to send a
 friend to invitation.

> Why I uses the UUID as referral_code?

I tried to use different type of autocreate a referral_code, but if I tried to
create based on database everytime load and create a new one this will spend a good time,
so I was reading and check this https://github.com/hashicorp/nomad/issues/54 that they
 uses the first 8 chars from a uuid.

> Why I use a simple Phoenix and Ecto app, instead use Agent to create Profiles?
Well, I stated use Agent, cause this problem is looked like the exercism, but
there is some problems that have I a used Agent, like lost some pid when the API
is down, create and find by cpf or referral code a pid before save in postgres.
My first choice: https://gist.github.com/pedromcorreia/c5b34e431c886b55eff5fa69714d738d

> Authentication?
Why I didn't use a lib for use authentication, like Guardian, here I used a authentication 
just to check if exist user to load the account. 

# Application structure

- bankx_web: is our API that response for communicate with client.
- bankx: is our app that have all rules and communication with database.

 # Running the application

 Use the `$ iex -S mix phx.server` to run the application.

 # Create database.

 Use the `$ mix setup_db` to create the database.

 # Testing

 Test all suite:

 `$ MIX_ENV=test mix coveralls`

 Be sure that the coverage is minimum 90%.
 
 # For testing in postman
 This show you how use API in real conditions.

 https://www.getpostman.com/collections/83a8cd18664af13964a8
 
 # Contributing

 To contribute, please follow some patterns:
  - Commit messages, documentation and all code related things in english;
  - Before open pull requests, make sure that `credo` was executed;

# Other app

I wrote a similar app: https://github.com/pedromcorreia/bank
