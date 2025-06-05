# 🔧 Nagios Core + Plugins + NRPE en Docker (Implementación Local)

Este proyecto contiene todo lo necesario para construir una imagen Docker que ejecute **Nagios Core**, junto con sus **plugins oficiales** y **cliente NRPE**, lista para monitorear recursos localmente.

---

## 📁 Estructura del proyecto

```
.
├── nagios-4.4.9/               # Código fuente de Nagios Core
├── nagios-plugins-2.4.2/       # Plugins oficiales
├── nrpe-4.1.0/                 # Cliente NRPE
├── .env                        # Variables de entorno (usuario/contraseña)
├── Dockerfile                  # Imagen completa Nagios + Apache
├── start.sh                    # Script de arranque
```

---

## 🚀 Despliegue local con Docker

### 1. Clona este repositorio

```bash
git clone <URL>
cd <nombre-del-directorio>
```

### 2. Define las credenciales

Edita el archivo `.env` y define las credenciales de acceso a la interfaz web:

```env
NAGIOSADMIN_USER=nagiosadmin
NAGIOSADMIN_PASSWORD=changeme123
```

---

### 3. Construye la imagen Docker

```bash
docker build -t nagios-local:1.0 .
```

---

### 4. Ejecuta el contenedor

```bash
docker run -d -p 80:80 --name nagios nagios-local:1.0
```

---

### 5. Accede a la interfaz web

Abre tu navegador y visita:

```
http://localhost/nagios
```

Ingresa las credenciales definidas en el archivo `.env`.

---

## 🧪 Verifica el estado del contenedor

```bash
docker ps
```

Y para ver los logs:

```bash
docker logs nagios
```

---

## 🧼 Detener y eliminar el contenedor

```bash
docker stop nagios
docker rm nagios
```

---

## 📄 Licencia

Este proyecto utiliza software open source bajo licencias GPLv2.  
Más información en [https://www.nagios.org](https://www.nagios.org)
