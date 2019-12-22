provider "google" {
  project = "infra-259917"
  region = "europe-west1"
}
resource "google_compute_address" "static" {
  name = "ipv4-address"
}
resource "google_compute_instance" "app" {
  name = "apache"
  machine_type = "n1-standard-1"
  zone = "europe-west1-b"
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20191113"
    }
  }
  metadata = {
    ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
  }
  tags = ["apang", "https-server", "http-server"]
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  connection {
    host = "35.240.35.104"
    type = "ssh"
    user = "appuser"
    agent = false
    private_key = "${file("~/.ssh/appuser")}"
  }
  provisioner "file" {
    source = "files/tomcat.service"
    destination = "/tmp/tomcat.service"
  }
  provisioner "file" {
    source = "files/tomcat-users.xml"
    destination = "/tmp/tomcat-users.xml"
  }
  provisioner "file" {
    source = "files/context.xml"
    destination = "/tmp/context.xml"
  }
  provisioner "remote-exec" {
    script = "files/apache.sh"
  }
}
resource "google_compute_firewall" "firewall_apache" {
  name = "allow-apache-default"
# Название сети, в которой действует правило
  network = "default"
# Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports = ["8080"]
  }
# Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
# Правило применимо для инстансов с тегом ...
  target_tags = ["apang"]
}
