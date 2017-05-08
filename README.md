# DockerBalancerSD

### Examen 2
**Universidad ICESI**  
**Curso:** Sistemas Distribuidos  

### Nombre: Dylan Dabian Torres
### Código: A00265772
### Repositorio GITHUB: https://github.com/dylan9538/DockerBalancerSD

### Objetivos
* Realizar de forma autónoma el aprovisionamiento automático de infraestructura
* Diagnosticar y ejecutar de forma autónoma las acciones necesarias para lograr infraestructuras estables
* Integrar servicios ejecutandose en nodos distintos

### Prerrequisitos
* Docker
* Imágenes de sistemas operativos a elección del estudiante

### Descripción del problema 
Aprovisionamiento	de	un	ambiente	compuesto	por	los	siguientes	elementos:	un servidor	encargado de	realizar balanceo de	carga,	tres	servidores	web	con páginas estáticas. Se	debe probar	el	funcionamiento	del balanceador	realizando peticiones y mostrando servidores distintos atendiendo las peticiones.

<p align="center">
  <img src="imagenes/diagrama_despliegue.png" width="650"/>
</p>

## Pasos preliminares

**GITHUB**

Para realizar la subida de archivos al repositorio en github se realizaran los siguientes pasos, o es importante tenerlos en cuenta:

Creamos dentro de la carpeta distribuidos un nuevo directorio llamado parcialUnoRepo:

```
mkdir parcialDosRepo
cd parcialDosRepo
```

**1)Clono el repositorio que necesito**

En este repositorio añadiremos los archivos que se manejen.

```
git clone https://github.com/dylan9538/SDBalancerDocker.git
cd SDBalancerDocker

git config remote.origin.url "https://token@github.com/dylan9538/SDBalancerDocker.git"
```
En el campo token añado el token generado en github.

**2)subir archivos**

1)Creo el archivo si no existe.

2)Sigo los siguientes comandos:
Estos comandos los ejecuto donde se encuentra ubicado el archivo a cargar.

```
git add nombreArchivo
git commit -m "upload README file"
git push origin master
```
## SOLUCION DEL PROBLEMA

### Consignación de los comandos de linux necesarios para el aprovisionamiento de los servicios solicitados (PRE)

**Usaremos Nginx que permite realizar el balanceo de carga necesario:**

**¿Que es nginx?**

Es un servidor web/proxy inverso ligero de alto rendimiento y un proxy para protocolos de correo electrónico. Es software libre y de código abierto; también existe una versión comercial distribuida bajo el nombre de nginx plus. Es multiplataforma, por lo que corre en sistemas tipo Unix (GNU/Linux, BSD, Solaris, Mac OS X, etc.) y Windows.

**Web**
Para el despliegue del servidor web de apache ejecutamos los siguientes comandos, primero se realiza la instalacion y luego se inicia el servicio:

``
sudo apt-get update
sudo apt-get install apache2
sudo service apache2 start
``

### Balancer nginx

Primero se instala nginx, ejecuntando los siguientes comandos:

```
sudo apt-get update
sudo apt-get install Nginx
```

Luego de instalar nginx se configura el archivo nginx.conf con el siguiente contenido:

``
worker_processes 3;
events { worker_connections 1024; }
http {
    sendfile on;
    upstream app_servers {
        server server_1;
        server server_2;
        server server_3;
    }
    server {
        listen 80;
        location / {
            proxy_pass         http://app_servers;
            proxy_redirect     off;
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
        }
    }
}
``

Luego procedemos a corre el servicio del balanceador y ejecutamos los siguientes comandos donde abrimos el puerto definido en el archivo de configuración anterior:

``
 iptables -I INPUT -p tcp --dport 8080 --syn -j ACCEPT
 service iptables save
 service iptables restart
 service nginx start
``

Luego de ejecutar el comando anterior probamos en el browser si nuestro balanceador de carga esta funcionando digitando la ip del balanceador y el puerto 8080. 

### SOLUCIÓN PROPUESTA PARA AUTOMATIZAR

Primero fue esenciar tenes descargadas las imagenes de httpd (para los servicios web) y nginx (para el balanceador). Para ello se siguieron los siguientes comandos:

```
docker pull httpd
docker pull nginx
```

**Para el desarrollo de los contenedores se usa Docker como herramienta**

A continuación se explicara paso a paso el desarrollo de cada uno de los files necesarios para la creación y caracterización de los contenedores web y el contenedor del balanceador (nginx). 

**Primero se empieza por el contenedor del balanceador de carga**

Se crea un directorio llamado Container balancer, donde encontraremos los siguientes archivos.

Primero se tiene el Dockerfile con el siguiente contenido, el cual contiene configuración necesaria para trabajar con el nginx instalado ya:

```
#Se usa el contenedor con nginx pre instalado
FROM nginx

#delete configuration file default
RUN rm /etc/nginx/conf.d/default.conf && rm -r /etc/nginx/conf.d

#add nginx's configuration file
ADD nginx.conf /etc/nginx/nginx.conf

#Container don't stop execution
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD service nginx start
```

Luego tenemos el archivo llamado nginx.conf con el siguiente contenido, en el cual se especifican la cantidad de servidores web que se utilizaran en el balanceo de carga y se especifica que trabajara como proxy:

```
worker_processes 3;
events { worker_connections 1024; }
http {
    sendfile on;
    upstream app_servers {
        server server_1;
        server server_2;
        server server_3;
    }
    server {
        listen 80;
        location / {
            proxy_pass         http://app_servers;
            proxy_redirect     off;
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
        }
    }
}
```

**Luego se realiza la configuración del contenedor web**

En este contenedor tendremos principalmente dos partes que se presentan acontinuación:

Primero encontramos el Dockerfile que contiene lo siguiente:

```
FROM httpd
MAINTAINER Dylan Torres

##Se bajan los recursos confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 /usr/local/bin/confd
ADD files/start.sh /start.sh

RUN chmod +x /usr/local/bin/confd
RUN chmod +x /start.sh

ADD files/confd /etc/confd

CMD ["/start.sh"]
```

Se especifica que el contenedor usara para la parte de web Apache (httpd) 



