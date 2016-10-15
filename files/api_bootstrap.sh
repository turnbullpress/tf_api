#!/bin/bash
sudo apt-get update
sudo apt-get install -y nodejs npm
sudo ln -s `which nodejs` /usr/bin/node
sudo npm install -g json-server
sudo mkdir -p /opt/json-server
sudo mkdir -p /opt/json-server/public

# Write db.json
sudo cat >/opt/json-server/index.js << "EOF"
// index.js
module.exports = function() {
  var data = { users: [] }
  // Create 1000 users
  for (var i = 0; i < 1000; i++) {
    data.users.push({ id: i, name: 'user' + i })
  }
  return data
}
EOF

# Write routes.json
sudo cat >/opt/json-server/routes.json << "EOF"
{
  "/api/": "/"
}

EOF

# Create index.html
sudo cat >/opt/json-server/public/index.html << "EOF"
<html>
  <head>
    <title>API service</title>
  </head>
  <body>
    <h1>The Terraform Book API service</h1>
  </body>
</html>
EOF

# Create server flags
cat >/tmp/json_server_flags << EOF
JSON_SERVER_FLAGS='--watch /opt/json-server/index.js --static /opt/json-server/public --routes /opt/json-server/routes.json --port 80'
EOF

# Write systemd service
cat >/tmp/json-server.service << "EOF"
[Unit]
Description=json server
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/default/json-server
Restart=on-failure
ExecStart=/usr/local/bin/json-server $JSON_SERVER_FLAGS
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

echo "Installing Systemd service..."
sudo chown root:root /tmp/json-server.service
sudo mv /tmp/json-server.service /etc/systemd/system/json-server.service
sudo chmod 0644 /etc/systemd/system/json-server.service
sudo mv /tmp/json_server_flags /etc/default/json-server
sudo chown root:root /etc/default/json-server
sudo chmod 0644 /etc/default/json-server
sudo systemctl enable json-server.service
sudo systemctl start json-server

