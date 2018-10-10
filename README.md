# WebManageUsers

Веб интерфейс, написанный на perl5 с использованием mojolicious, для реализации регистрации и авторизации пользователей.
База данных: postgresql.
    
##Установка

```
cpan Mojo
cpan DBI
cpan DBD::Pg
cpan Modern::Perl
cpan Crypt::Random
cpan Crypt::Eksblowfish::Bcrypt
git clone https://github.com/xmolex/WebManageUsers.git
```
Создайте базу и загрузите в нее sql из файла install.sql
Поправьте настройки в web_manage_users.conf

##Запуск

morbo -l "http://*:9000" script/web_manage_users
    
    