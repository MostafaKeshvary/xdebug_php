WSL_HOST_IP := $(shell grep nameserver /etc/resolv.conf | awk '{print $$2}')

up:
	@echo "🔍 Detecting WSL Host IP..."
	@echo "➡️  WSL Host IP detected: $(WSL_HOST_IP)"
	@if grep -q '^WSL_HOST_IP=' .env 2>/dev/null; then \
		sed -i "s/^WSL_HOST_IP=.*/WSL_HOST_IP=$(WSL_HOST_IP)/" .env; \
	else \
		echo "WSL_HOST_IP=$(WSL_HOST_IP)" >> .env; \
	fi
	@echo "✅ .env updated with WSL_HOST_IP=$(WSL_HOST_IP)"
	@echo "🚀 Starting Docker containers..."
	docker-compose up -d
	@echo "✅ Docker is up and running!"
	@echo "⚠️  Reminder: Windows Firewall may block Xdebug connections on port 9003."
	@echo "⚠️  To allow Xdebug traffic, run command bellow in cmd as Administrator:"
	@echo "     1netsh advfirewall firewall add rule name=\"Allow Xdebug\" dir=in action=allow protocol=TCP localport=9003"


down:
	@echo "🛑 Stopping Docker containers..."
	docker-compose down
	@echo "✅ All containers stopped."

restart:
	@echo "♻️ Restarting Docker environment..."
	make down
	make up
	@echo "✅ Restart complete!"
