% Terraform Language
% Sergey Korobitsin
% Сентябрь 2022

## О докладчике

![](img/bird.jpg)

- Руковожу инфраструктурой в Smart Cities
- Строю с коллегами Aitu.Cloud
- Живу с Terraform с 2018 
- Начал с версии 0.11, сейчас 1.0.7
- Написал ~10k SLOC на HCL (в основном модули)

## Terraform DSL: зачем

Domain Specific Language

![](img/zatem.jpg)

## Terraform DSL: зачем

- Maintainability
- Not being Turing-complete is a feature =>
- Скорость работы и проверка типов
- Проблемы развития: list/tuple и map/object, нет нативных тестов
- Экспериментальные фичи:

  ```ruby
  terraform {
    experiments = [example]
  }
  ```

## Проверка гипотез (1)

Проверка выражений (REPL): Terraform Console

```ruby
$ terraform console
> "Hello Terraform"
"Hello Terraform"
> { for key, value in { "verb" = "Hello", "subject" = "Terraform" }: 
  "Key: ${key}" => "Value: ${value}" }
{
  "Key: subject" = "Value: Terraform"
  "Key: verb" = "Value: Hello"
}
```

## Проверка гипотез (2)

Ресурс `random_pet` провайдера `hashicorp/random`:

```ruby
resource "random_pet" "a-creature-living-in-my-house" {
}
```

## Language: Syntax

```ruby
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```

## Language: Files, Directories, Modules

- Unicode, UTF-8 Encoding
- Файлы `*.tf` (`*.tf.json`) в одном каталоге - корневой модуль 
- Каталог может быть подключен как модуль внутри другого модуля
- Overrides

## Input variables, Output values

- Входные - параметры модуля:

  ```ruby
  variable "image_id" {
    type = string
  }
  ```

- Возвращаемые значения: 

  ```ruby
  output "instance_ip_addr" {
    value = aws_instance.server.private_ip
  }
  ```

## Local values

- Локальные переменные:

  ```ruby
  locals {
    service_name = "forum"
    owner        = "Community Team"
  }
  ```

## Expressions

- Литералы ("somestring", 123) и вычисления
- Строки и шаблоны строк
- Арифметика, сравнения, логика
- **Встроенные** функции
- Условия, циклы
- Типы и их органичения

## Строки

```ruby
"literal string"
```

```ruby
"string with interpolation of ${var.something}"
```

```ruby
somearg = <<EOT
heredoc here!
Interpolaton ${local.otherthing} works too
EOT
```

## Шаблоны строк

Директива - `%{}`

```ruby
"Hello, %{ if var.name != "" }${var.name}%{ else }stranger%{ endif }!"
```

```ruby
meta_data = <<EOT
local-hostname: ${var.hostname[0]}
bootcmd:
%{ for iface in var.network_interfaces ~}
  - ifdown ${iface.interface}
  - ifup ${iface.interface}
%{ endfor ~}
EOT
```

## Арифметика, сравнения, логика

```ruby
locals {
  myloc = var.a + var.b - var.c * var.d / var.e % var.f
  boolean1 = var.a == var.b
  boolean2 = var.c != var.d
  boolean3 = var.e >= var.f
  boolean4 = local.boolean1 && local.boolean2
  boolean5 = !local.boolean3
}
```

## Функции - вызов

```ruby
<FUNCTION NAME>(<ARGUMENT 1>, <ARGUMENT 2>)
```

- Почти все функции - чистые
- Исключения: `file()`, `templatefile()`
- Исключения: `timestamp()`, `uuid()`

## Функции - виды (1)

- Числовые - `min()`, `max()`, `ceil()`, `floor()` и др.
- Строковые - `join()`, `split()`, `format()` и др.
- Работа с коллекциями - `keys()`, `values(), `merge()` и др.
- Кодирование - `jsonencode()`, `yamldecode()`, `base64encode()` и др.
- Файловые - `file()`, `templatefile()` `basename()`, `dirname()` и др.

## Функции - виды (2)

- Работа с датами и временем - `formatdate()` и др.
- Хэши и криптография - `sha256()`, `filesha1()`, `rsadecrypt()` и др.
- Работа с IP-адресами - `cidrhost(), `cidrnetmask()` и др.
- Преобразования типов - `toset()`, `tostring()`. `try()`, `can()` и др.

## Условия

Тернарный оператор:

```ruby

expr_returning_bool ? expr_if_true : expr_if_false

```

## Циклы в выражениях (1)

- Циклы принимают коллекции и возвращают коллекции
- Цикл, возвращающий список:

  ```ruby
  [ for mac in var.mac_addresses : upper(mac) ]
  ```

- Цикл, возвращающий map:

  ```ruby
  { for mac, ip in var.addresses : upper(mac) => ip }
  ```

## Циклы в выражениях (2)

- Фильтрация значений

  ```ruby
  [ for user, attrs in var.users : user if user.is_admin ]
  ```

## Циклы в ресурсах

   ```ruby
   locals {
     family_members = ["me", "mom", "aunt"]
   }
   resource "random_pet" "pet" {
     for_each = toset(local.family_members)
   }
   ```

## Циклы в ресурсах - динамические блоки

```ruby
resource "openstack_compute_instance_v2" "generic-vm" {
  name            = var.name

  dynamic "network" {
    for_each = openstack_networking_port_v2.port
    iterator = port
    content {
      port = port.value.id
    }
  }
}
```

## Типы

Поддержка типов и тайпчекер - добавлялись эволюционно

- Примитивные и комплексные типы - скаляры и коллекции
- + структурные типы
- Скаляры: `string`, `number`, `bool`
- Коллекции: `map`, `list`, `set`
- Структурные: `object`, `tuple`

## Типы (2)

- Динамические типы - `any`
- Опциональные элементы в типе (1.3.x)
