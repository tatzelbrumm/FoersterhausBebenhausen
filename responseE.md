**Einführung**

Die Modellierung eines Materials, das sowohl ferromagnetische Eigenschaften (mit Sättigung) als auch elektrische Leitfähigkeit aufweist, stellt in SPICE eine komplexe Herausforderung dar. SPICE ist primär für die Simulation elektrischer Schaltungen konzipiert und bietet nur begrenzte Möglichkeiten zur direkten Modellierung magnetischer Materialien und ihrer nichtlinearen Eigenschaften wie Hysterese und Sättigung. Dennoch gibt es Methoden, um diese Eigenschaften zu approximieren und ein SPICE-kompatibles Modell zu erstellen, das sowohl die ferromagnetischen als auch die leitfähigen Eigenschaften des Materials berücksichtigt.

---

### **Vorgehensweise zur Modellierung**

**1. Kombination von magnetischen und elektrischen Modellen**

Um beide Eigenschaften zu modellieren, müssen Sie eine Kombination aus einem nichtlinearen Induktivitätsmodell für die ferromagnetischen Eigenschaften und einem Widerstandsmodell für die elektrische Leitfähigkeit erstellen.

---

#### **a. Modellierung der ferromagnetischen Eigenschaften mit Sättigung**

**Nichtlineare Induktivität**

- Verwenden Sie eine nichtlineare Induktivität, deren Induktivität vom Strom abhängt, um die Sättigungseffekte des ferromagnetischen Materials zu simulieren.

**Implementierung in SPICE**

- Definieren Sie eine Induktivität mit einer Strom-abhängigen Induktivität $L(I)$:

  ```spice
  .func Lcore(I) = {L0 / (1 + (I / Isat) ^ n)}
  L1 Knoten1 Knoten2 L = Lcore(I(L1))
  ```

  - $L0$: Anfangsinduktivität (bei niedrigen Strömen).
  - $Isat$: Sättigungsstrom des Materials.
  - $n$: Parameter, der die Steilheit der Sättigungskurve bestimmt.

**Berücksichtigung der Hysterese (optional)**

- Wenn Hystereseeffekte wichtig sind, können Sie versuchen, ein Hysterese-Modell zu implementieren, z. B. das Jiles-Atherton-Modell, obwohl dies in SPICE schwierig umzusetzen ist.

---

#### **b. Modellierung der elektrischen Leitfähigkeit**

**Resistives Element**

- Modellieren Sie die elektrische Leitfähigkeit durch einen Widerstand, der den spezifischen Widerstand des Materials repräsentiert.

**Implementierung in SPICE**

- Fügen Sie einen Widerstand parallel zur Induktivität hinzu:

  ```spice
  R1 Knoten1 Knoten2 {R_material}
  ```

  - $R_{\text{material}}$: Widerstandswert, berechnet aus dem spezifischen Widerstand und den geometrischen Abmessungen des Materials.

---

#### **c. Gesamtes Modell**

**Parallelschaltung von Induktivität und Widerstand**

- Durch die Parallelschaltung der nichtlinearen Induktivität und des Widerstands erhalten Sie ein Modell, das sowohl die magnetischen als auch die elektrischen Eigenschaften berücksichtigt.

**Schaltplan**

```
    Knoten1 ----+---- L1 (nichtlineare Induktivität) ----+---- Knoten2
                |                                        |
                +---- R1 (Widerstand) -------------------+
```

---

### **Beispiel-SPICE-Netzliste**

```spice
* Parameterdefinitionen
.param L0 = 10m      ; Anfangsinduktivität in Henry
.param Isat = 1A     ; Sättigungsstrom
.param n = 2         ; Sättigungssteilheit
.param R_material = 0.1 ; Widerstandswert in Ohm

* Funktion für die nichtlineare Induktivität
.func Lcore(I) = {L0 / (1 + (I / Isat) ^ n)}

* Nichtlineare Induktivität
L1 Knoten1 Knoten2 L = Lcore(I(L1))

* Widerstand zur Modellierung der Leitfähigkeit
R1 Knoten1 Knoten2 {R_material}

* Spannungsquelle zur Anregung
V1 Knoten1 0 SIN(0 1 50k)

* Simulationseinstellungen
.tran 0 10m 0 1u
.probe I(V1) V(Knoten1) V(Knoten2)
.end
```

---

### **Wichtige Überlegungen**

**1. Frequenzabhängigkeit**

- Die magnetischen und elektrischen Eigenschaften des Materials können frequenzabhängig sein. Berücksichtigen Sie dies gegebenenfalls durch Anpassung der Modellparameter oder durch Hinzufügen von frequenzabhängigen Elementen.

**2. Temperaturabhängigkeit**

- Sowohl die ferromagnetischen Eigenschaften als auch die Leitfähigkeit können temperaturabhängig sein. Falls relevant, können Sie Temperaturkoeffizienten in das Modell einbeziehen.

**3. Genauigkeit des Modells**

- Dieses vereinfachte Modell berücksichtigt nicht alle komplexen Phänomene wie Hysterese, Wirbelströme oder Skin-Effekte, die in realen Materialien auftreten können. Für genauere Simulationen könnten spezialisierte Softwaretools oder erweiterte Modelle erforderlich sein.

---

### **Erweiterte Modellierung**

**Inklusive Wirbelströme**

- **Verlustwiderstand:** Fügen Sie einen frequenzabhängigen Widerstand hinzu, um Wirbelstromverluste zu simulieren.

  ```spice
  .func R_loss(f) = {k * sqrt(f)}
  ```

  - $k$: Proportionalitätskonstante, die von den Materialeigenschaften abhängt.

**Skin-Effekt**

- **Induktivität und Widerstand in Abhängigkeit von der Frequenz anpassen:** Verwenden Sie komplexere Modelle, um die Auswirkungen des Skin-Effekts bei höheren Frequenzen zu berücksichtigen.

---

### **Alternativen zu SPICE**

- **Spezialisierte Simulationssoftware:** Für eine detailliertere Analyse könnten Sie elektromagnetische Simulationssoftware wie Ansys Maxwell oder COMSOL Multiphysics verwenden, die speziell für die Modellierung komplexer magnetischer und leitender Materialien entwickelt wurden.

- **Verilog-A Modelle:** In einigen SPICE-Versionen können Sie Verilog-A verwenden, um benutzerdefinierte Modelle zu erstellen, die komplexere physikalische Phänomene berücksichtigen.

---

### **Zusätzliche Ressourcen**

- **Herstellerdokumentation:** Hersteller von ferromagnetischen Materialien oder Kernen bieten oft technische Datenblätter und Anwendungshinweise, die nützliche Informationen für die Modellierung enthalten.

- **Fachliteratur:** Forschungspublikationen und Bücher über elektromagnetische Materialeigenschaften und deren Simulation können weitere Einblicke bieten.

---

### **Fazit**

Die Erstellung eines SPICE-kompatiblen Modells für ein Material, das sowohl ferromagnetische Eigenschaften mit Sättigung als auch elektrische Leitfähigkeit aufweist, erfordert die Kombination von nichtlinearen Induktivitäten und Widerständen. Obwohl SPICE in seiner Standardform begrenzte Möglichkeiten zur direkten Modellierung komplexer magnetischer Phänomene bietet, können durch geschickte Nutzung von nichtlinearen Bauelementen und funktionalen Abhängigkeiten akzeptable Annäherungen erzielt werden. Für präzisere Modelle sollten spezialisierte Tools oder erweiterte Modellierungstechniken in Betracht gezogen werden.

---

**Wenn Sie weitere Fragen haben oder Hilfe bei der Umsetzung des Modells benötigen, stehe ich gerne zur Verfügung!**
