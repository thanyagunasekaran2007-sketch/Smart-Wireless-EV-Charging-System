# Auto-Trigger Portable Wireless EV Charger: Java-Based Charging Management System

A complete Java full-stack application for simulating and managing wireless EV charging sessions.

> **Important Simulation Disclaimer:** This software is an educational **simulation and management interface** for a compact portable wireless EV charger targeting electric 2-wheelers and 3-wheelers. It does **not** control physical power electronics or hardware sensors. Vehicle detection, coil alignment, and ambient/pad temperatures are simulated through the frontend interface.

---

## 1. Architecture Overview

The application follows a clean, layered Spring Boot architecture:

- **Presentation Layer (`controller/` + Thymeleaf + Bootstrap 5 + Chart.js):**
  - `WebDashboardController`: Serves the responsive dark-navy and electric-blue pages (`Dashboard`, `New Charging Session`, `Charging History`, and `Analytics`).
  - `RestApiController`: Exposes JSON REST endpoints under `/api/**`.
- **Service Layer (`service/`):**
  - `ChargingService`: Orchestrates EV creation, `ChargingManager` simulation, and persistence of every attempted session (both completed and blocked).
  - `SessionDataService`: Manages database queries, multi-criteria filtering/sorting, and initial sample session generation.
  - `DashboardService`: Dynamically computes all dashboard KPIs, Chart.js series, and descriptive statistics (`Mean`, `Min`, `Max`, `StdDev`) from H2 database records.
- **Domain & Simulation Core (`model/` & `config/`):**
  - `EV`, `PortableCharger`, `ChargingManager`, `ConditionMonitor` (interface), `AbstractConditionMonitor` (abstract base class), `AlignmentMonitor`, `TemperatureMonitor`, and `BatteryMonitor`.
  - `SimulationProperties`: Externalizes all mathematical simulation assumptions in `application.properties`.
- **Persistence Layer (`entity/` & `repository/`):**
  - `ChargingSession` JPA entity persisted in a file-based H2 database (`./data/ev_charger_db`).

---

## 2. Java Design & Implementation

| Java Concept | Implementation Location & Purpose |
| :--- | :--- |
| **Classes & Objects** | `EV`, `PortableCharger`, `MonitorCheckResult`, `ChargingCalculationResult`, `ChargingSession` |
| **Encapsulation** | Private fields with validated getters/setters in `EV`, `PortableCharger`, `ChargingSession`, `SimulationProperties` |
| **Constructors & Overloading** | Overloaded constructors in `EV`, `PortableCharger`, `ChargingSession`, and DTO classes |
| **Interfaces & Polymorphism** | `ConditionMonitor` interface implemented by `AlignmentMonitor`, `TemperatureMonitor`, and `BatteryMonitor`; iterated polymorphically in `ChargingManager` |
| **Inheritance** | `AbstractConditionMonitor` abstract base class extended by `AlignmentMonitor`, `TemperatureMonitor`, and `BatteryMonitor` |
| **Enums** | `VehicleType`, `AlignmentStatus`, `EnergySource`, and `ChargingStatus` |
| **ArrayList & List** | `ChargingManager.conditionMonitors`, `workflowLogs`, `SessionDataService.searchAndSortSessions()`, `DashboardService` statistical lists |
| **HashMap / LinkedHashMap / TreeMap** | `ChargingManager.getConfiguredCapacityMap()`, `DashboardService` status/EV-type/date aggregations |
| **Conditionals & Loops** | Pre-charge monitor checks, search/filter loops, descriptive statistics (`mean`, `min`, `max`, `stdDev`) calculations |
| **Exception Handling** | Custom `SessionNotFoundException`, `InvalidChargingParameterException`, and `@ControllerAdvice` `GlobalExceptionHandler` |
| **Spring Dependency Injection** | Constructor-based DI across all `@Service`, `@Component`, and `@Controller` classes |
| **Bean Validation** | Jakarta Validation annotations (`@NotBlank`, `@NotNull`, `@Min`, `@Max`, `@DecimalMin`, `@DecimalMax`) in `ChargingSessionRequestDto` |

---

## 3. Mathematical Simulation Model & Rules

Configured in `src/main/resources/application.properties` via `SimulationProperties`:
- **Nominal Battery Capacity ($C_{\text{battery}}$):**
  - `2-Wheeler`: $3.2\text{ kWh}$
  - `3-Wheeler`: $7.5\text{ kWh}$
- **Nominal Wireless Charger Power ($P_{\text{nominal}}$):** $3.3\text{ kW}$
- **Thermal Demonstration Thresholds:**
  - Warning Zone: $40.0^\circ\text{C} \le T \le 45.0^\circ\text{C}$ (triggers a `Temperature warning` and applies $12\%$ thermal power derating)
  - Cutoff Threshold: $T > 45.0^\circ\text{C}$ or $T < -10.0^\circ\text{C}$ (blocks charging with `BLOCKED_TEMPERATURE`)
- **Coil Alignment Rule:**
  - `Good`: Passes check
  - `Poor`: Blocks charging with `BLOCKED_ALIGNMENT`
- **Energy & Duration Equations (when all checks pass):**
  - **Net Energy Delivered to Battery ($\text{kWh}$):**
    $$E_{\text{delivered}} = \frac{\text{Target\%} - \text{Start\%}}{100} \times C_{\text{battery}}$$
  - **Simulated Wireless Efficiency ($\eta\%$):**
    $$\eta = 91.5\% - \max(0, T - 25.0) \times 0.22\% + \Delta\eta_{\text{source}}$$
  - **Gross Energy Consumed from Source ($\text{kWh}$):**
    $$E_{\text{consumed}} = \frac{E_{\text{delivered}}}{\eta / 100}$$
  - **Charging Duration ($\text{min}$):**
    $$T_{\text{min}} = \left(\frac{E_{\text{delivered}}}{P_{\text{effective}}}\right) \times 60$$

---

## 4. How to Run in Eclipse, IntelliJ IDEA, VS Code, or Terminal

### Prerequisites
- **Java 17 or later** (JDK 17, 21, or 25/26)
- **Maven** (bundled in IDEs or via `mvn`)

### Option A: Run in IntelliJ IDEA / Eclipse / VS Code
1. Open the folder `ev_charger` as an **Existing Maven Project**.
2. Wait for Maven dependencies to finish indexing.
3. Locate `src/main/java/com/evcharger/EvChargerApplication.java`.
4. Right-click `EvChargerApplication.java` and click **Run 'EvChargerApplication.main()'**.
5. Open your browser at: **`http://localhost:8080`**

### Option B: Run via Terminal
```bash
mvn spring-boot:run
```
To execute the automated JUnit 5 test suite:
```bash
mvn test
```

### H2 Database Console Access
- URL: `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:file:./data/ev_charger_db;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE`
- User Name: `sa`
- Password: *(leave blank)*
