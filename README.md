Запустить vagrant up.

#### Port knocking
Для проверки knockd необходимо зайти на centralServer, запустить скрипт knock_openssh.sh

* #sudo -i
* #sh knock_openssh.sh

После этого можно будет подключиться по ssh к хосту 192.168.255.1 (inetRouter)  
Пароль дефолтный: vagrant

Для закрытия порта необходимо запустить скрипт knock_closessh.sh

* #sh knock_closessh.sh

#### Проброс порта
На centralServer поднят nginx.

На публичном интерфейсе inetRouter2 назначен адрес 192.168.11.50.  
Настроен проброс порта с 192.168.11.50:8080(inetRouter2) на 192.168.0.2:80   (centralServer).

Для проверки доступности запустить curl 192.168.11.50:8080 или открыть в браузере:  
 http://192.168.11.50:8080/ (откроется стандартная страница nginx)
