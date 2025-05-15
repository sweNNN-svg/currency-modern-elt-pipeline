## Currency Modern ELT Pipeline



![ELT Architecture Diagram](https://github.com/sweNNN-svg/currency-modern-elt-pipeline/raw/main/docs/architecture.png)

Bu proje, modern veri mühendisliği araçlarını kullanarak geliştirilen uçtan uca bir ELT (Extract, Load, Transform) çözümüdür. Amaç, döviz kuru verilerini saatlik olarak toplayıp PostgreSQL'e yüklemek, bu verileri dbt ile dönüştürmek ve Grafana ile görselleştirmektir.

### Bileşenler

* **Airbyte**: Kaynaktan (Exchange Rates API) veri çekmek ve hedef sisteme (PostgreSQL) yüklemek için kullanılır.
* **PostgreSQL**: Ham ve dönüştürülmüş verilerin saklandığı ilişkisel veritabanıdır.
* **dbt (Data Build Tool)**: SQL tabanlı veri dönüşümleri ve veri ambarı modellemeleri için kullanılır.
* **Grafana**: PostgreSQL üzerindeki verilerin görselleştirilmesi için kullanılır.
* **Docker Compose**: Tüm bileşenlerin izole servisler olarak ayağa kaldırılmasını sağlar.

### Proje Yapısı (Dosya ve Klasörler)

```
currency_modern_elt/
├── airbyte/
│   ├── sources/
│   │   └── exchange_rates_api.yaml
│   └── destination/
│       └── postgres_currency.yaml
├── dbt/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_exchange_rates.sql
│   │   └── marts/
│   ├── tests/
│   │   └── data_quality_tests.sql
│   └── dbt_project.yml
├── grafana/
│   └── dashboards/
│       └── currency_dashboard.json
├── docker-compose.yml
├── docs/
│   └── architecture.png
```

### Akış (Pipeline Flow)

1. **Airbyte Source**: `exchange_rates_api.yaml` dosyası ile ExchangeRates API'den veriler çekilir.
2. **Airbyte Destination**: `postgres_currency.yaml` ile veriler PostgreSQL'e yazılır.
3. **Ham Veri Tabanı**: `exchange_rates_raw` tablosuna veri yüklenir.
4. **dbt Transform**:

   * `stg_exchange_rates.sql` ile ham veri dönüştürülür:

     ```sql
     with raw as (
       select json_each_text(raw_column::json) as kv
       from exchange_rates_raw
     )
     select
       'TRY' as base_currency,
       kv.key as target_currency,
       kv.value::float as rate,
       current_timestamp as last_updated
     from raw;
     ```
   * Bu sorgu, JSON içindeki döviz kurlarını `base_currency`, `target_currency`, `rate` ve `last_updated` sütunlarıyla normalize eder.
5. **dbt Tests**: `data_quality_tests.sql` dosyası ile kalite kontrolleri yapılır.
6. **Grafana**: `currency_dashboard.json` ile PostgreSQL'deki veriler görselleştirilir.

### Başlatma

```bash
docker-compose up -d
```

Tüm servisler arka planda ayağa kalkar. Daha sonra Airbyte UI'dan kaynak ve hedef ayarlanır, dbt komutları CLI üzerinden çalıştırılır:

```bash
cd dbt
dbt run
dbt test
```

### Notlar

* Airbyte UI: [http://localhost:8000](http://localhost:8000)
* Grafana UI: [http://localhost:3000](http://localhost:3000)
* PostgreSQL: port 5432, kullanıcı/parola: `airbyte/airbyte`

### Katkı

Bu proje bireysel bir ELT pipeline örneğidir. İleride Kafka, Flink, Delta Lake gibi bileşenlerle zenginleştirilebilir.
