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
	@echo "⚠️  To allow Xdebug traffic, run the PowerShell script as Administrator:"
	@echo "     1️⃣  Open PowerShell as Administrator"
	@echo "     2️⃣  Navigate to the folder containing 'toggle-wsl-firewall.ps1'"
	@echo "     3️⃣  Execute the script: '.\\\\toggle-wsl-firewall.ps1'"
	@echo "     4️⃣  Follow the interactive prompts to disable the firewall for WSL"


down:
	@echo "🛑 Stopping Docker containers..."
	docker-compose down
	@echo "✅ All containers stopped."

restart:
	@echo "♻️ Restarting Docker environment..."
	make down
	make up
	@echo "✅ Restart complete!"
