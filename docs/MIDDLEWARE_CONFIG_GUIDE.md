# 中间件配置管理指南

> **最后更新**: 2026-01-20
> **适用版本**: CCG v1.1.0+

---

## 📖 目录

1. [配置存放位置](#配置存放位置)
2. [配置文件结构](#配置文件结构)
3. [最佳实践](#最佳实践)
4. [常见中间件配置](#常见中间件配置)

---

## 配置存放位置

### 推荐方案：分层配置

```
项目根目录/
├── .env.example              # 环境变量模板（提交到 Git）
├── .env                      # 本地环境变量（不提交）
├── config/                   # 配置目录
│   ├── development.yml       # 开发环境配置（提交）
│   ├── production.yml        # 生产环境配置（提交）
│   └── local.yml.example     # 本地配置模板（提交）
├── docker-compose.yml        # Docker 编排（提交）
└── docs/
    └── MIDDLEWARE_SETUP.md   # 中间件配置文档（提交）
```

### 配置分类

| 配置类型 | 存放位置 | 是否提交 Git | 说明 |
|---------|---------|-------------|------|
| **敏感信息** | `.env` | ❌ 否 | 密码、密钥、Token |
| **环境变量模板** | `.env.example` | ✅ 是 | 变量名和说明 |
| **中间件连接信息** | `config/*.yml` | ✅ 是 | 使用环境变量占位符 |
| **Docker 配置** | `docker-compose.yml` | ✅ 是 | 本地开发用 |
| **配置文档** | `docs/MIDDLEWARE_SETUP.md` | ✅ 是 | 安装和配置说明 |

---

## 配置文件结构

### 1. 环境变量文件 (.env)

**用途**: 存储敏感信息和环境特定配置

**示例** (`.env`):
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=postgres
DB_PASSWORD=your_secret_password

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# 消息队列配置
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=your_rabbitmq_password

# API 密钥
API_KEY=your_api_key
SECRET_KEY=your_secret_key
```

**模板** (`.env.example`):
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=postgres
DB_PASSWORD=change_me

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=change_me

# 消息队列配置
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=change_me

# API 密钥
API_KEY=your_api_key_here
SECRET_KEY=your_secret_key_here
```

---

### 2. 应用配置文件 (config/*.yml)

**用途**: 存储中间件连接配置，使用环境变量占位符

**示例** (`config/development.yml`):
```yaml
database:
  host: ${DB_HOST}
  port: ${DB_PORT}
  name: ${DB_NAME}
  user: ${DB_USER}
  password: ${DB_PASSWORD}
  pool_size: 10
  timeout: 5000

redis:
  host: ${REDIS_HOST}
  port: ${REDIS_PORT}
  password: ${REDIS_PASSWORD}
  db: 0
  max_connections: 50

rabbitmq:
  host: ${RABBITMQ_HOST}
  port: ${RABBITMQ_PORT}
  user: ${RABBITMQ_USER}
  password: ${RABBITMQ_PASSWORD}
  vhost: /
```

---

### 3. Docker Compose 配置

**用途**: 本地开发环境的中间件编排

**示例** (`docker-compose.yml`):
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "${DB_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - redis_data:/data

  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    ports:
      - "${RABBITMQ_PORT}:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
```

---

## 最佳实践

### 1. 安全原则

**✅ 应该做**:
- 将 `.env` 添加到 `.gitignore`
- 提供 `.env.example` 模板
- 使用环境变量占位符（`${VAR_NAME}`）
- 定期轮换密码和密钥

**❌ 不应该做**:
- 将密码硬编码在配置文件中
- 将 `.env` 提交到 Git
- 在代码中直接写密码
- 在日志中输出敏感信息

### 2. 配置分层

**开发环境** (`config/development.yml`):
- 使用本地中间件
- 宽松的超时设置
- 详细的日志级别

**生产环境** (`config/production.yml`):
- 使用远程中间件
- 严格的超时设置
- 精简的日志级别

### 3. 文档化

**必须提供**:
- 中间件安装说明
- 配置步骤
- 常见问题解决方案
- 连接测试命令

---

## 常见中间件配置

### PostgreSQL

**环境变量**:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=postgres
DB_PASSWORD=your_password
```

**连接测试**:
```bash
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
```

### Redis

**环境变量**:
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_password
```

**连接测试**:
```bash
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping
```

### RabbitMQ

**环境变量**:
```bash
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=your_password
```

**连接测试**:
```bash
# 访问管理界面
http://localhost:15672
# 用户名: admin, 密码: your_password
```

---

## 总结

**推荐配置方案**:
1. 敏感信息 → `.env`（不提交）
2. 配置模板 → `.env.example`（提交）
3. 中间件配置 → `config/*.yml`（提交，使用环境变量）
4. Docker 编排 → `docker-compose.yml`（提交）
5. 配置文档 → `docs/MIDDLEWARE_SETUP.md`（提交）

**关键原则**:
- ✅ 分离敏感信息和配置结构
- ✅ 使用环境变量占位符
- ✅ 提供完整的配置模板
- ✅ 文档化所有配置步骤

---

**最后更新**: 2026-01-20
**维护者**: CCG Team
