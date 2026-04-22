# Schweizer Zahlungsdateiformate - Interne Referenz

**Thema:** Normierte Dateiformate für den elektronischen Zahlungsverkehr in der Schweiz
**Standard:** ISO 20022 / Swiss Payment Standards (SPS)
**Herausgeber:** SIX (Swiss Interbank Clearing)
**Stand:** April 2026

## 1. Überblick

In der Schweiz basieren die normierten Dateiformate für die Übermittlung von Zahlungen zwischen Kunden und Banken auf dem internationalen **ISO 20022**-Standard. Die schweizspezifische Ausprägung heisst **Swiss Payment Standards (SPS)** und wird von SIX herausgegeben und gepflegt.

Die SPS decken zwei Bereiche ab:

- **pain** (Payment Initiation) - Meldungen vom Kunden an die Bank
- **camt** (Cash Management) - Meldungen von der Bank an den Kunden

Alle Meldungen werden als strukturierte XML-Dateien im UTF-8-Format übermittelt.

## 2. Die relevanten Formate im Überblick

### 2.1 Kunde an Bank (pain)

| Format | Bezeichnung | Zweck |
|---|---|---|
| **pain.001** | Customer Credit Transfer Initiation | Überweisungsaufträge (Einzel- oder Sammelzahlungen) |
| **pain.008** | Customer Direct Debit Initiation | Lastschriftaufträge (Einzugsermächtigungen) |
| **pain.002** | Customer Payment Status Report | Rückmeldung der Bank zum Validierungsstatus |

### 2.2 Bank an Kunde (camt)

| Format | Bezeichnung | Zweck |
|---|---|---|
| **camt.052** | Bank To Customer Account Report | Untertägiger Zwischenbericht |
| **camt.053** | Bank To Customer Statement | Tagesabschliessender Kontoauszug |
| **camt.054** | Bank To Customer Debit/Credit Notification | Belastungs- und Gutschriftanzeige (Nachfolger von BESR/VESR) |

### 2.3 QR-Rechnung

Die QR-Rechnung ist kein eigenständiges Dateiübermittlungsformat, sondern der Schweizer Ersatz für die roten und orangen Einzahlungsscheine. Sie liefert die Zahlungsinformationen (IBAN, Referenz, Betrag) per Swiss QR Code und wird als Datenbasis für eine pain.001 genutzt.

### 2.4 SWIFT-MT-Formate (teilweise noch im Einsatz)

Im Firmenkundengeschäft werden teils noch klassische SWIFT-Formate akzeptiert:

- **MT101** - Request for Transfer (Zahlungsauftrag)
- **MT940** - End-of-Day Statement (Kontoauszug)
- **MT942** - Interim Transaction Report (untertägig)

Diese Formate haben vorläufig noch kein Enddatum.

### 2.5 Abgelöste Altformate

Nur noch historisch relevant:

- **DTA** (Datenträgeraustausch) - ersetzt durch pain.001
- **EZAG** (PostFinance Einzahlungsauftrag) - ersetzt durch pain.001
- **BESR / VESR** (Einzahlungsschein mit Referenz) - ersetzt durch camt.054 bzw. QR-Rechnung
- **DD-CH / LSV+** (Lastschriftverfahren) - abgebildet über pain.008

## 3. Versionsumstellung bis November 2026

Seit November 2022 unterstützt der Schweizer Finanzplatz für pain.001 sowie camt.052, camt.053 und camt.054 zwei Schema-Versionen:

- **ISO 20022 Version 2009** (alt)
- **ISO 20022 Version 2019** (aktuell)

Die Version 2009 wird analog zu den internationalen Standards (SEPA und SWIFT) per **21. November 2026** eingestellt. Nur mit der Version 2019 werden Weiterentwicklungen wie Instant-Zahlungen unterstützt.

**Handlungsbedarf:** Alle Systeme, die pain- und camt-Dateien erzeugen oder verarbeiten, müssen rechtzeitig auf Version 2019 migriert sein. Für EBICS ist in diesem Zug die Version 3.0 erforderlich.

## 4. Aufbau einer pain.001-Datei

Eine pain.001-Datei ist ein XML-Dokument mit einer dreistufigen Hierarchie (A/B/C).

### 4.1 Die drei Ebenen

**Level A - Group Header (`GrpHdr`)**
Kopfdaten der gesamten Datei. Nur einmal pro Datei vorhanden.
- `MsgId` - eindeutige Datei-ID (max. 35 Zeichen)
- `CreDtTm` - Erstellungszeitpunkt (ISO-8601)
- `NbOfTxs` - Total aller Einzelzahlungen in der Datei
- `CtrlSum` - Summe aller Beträge
- `InitgPty` - Auftraggeber

**Level B - Payment Information (`PmtInf`)**
Zahlungsblock mit gemeinsamen Eigenschaften für eine Gruppe von Zahlungen. Pro Datei sind mehrere B-Level-Blöcke möglich.
- `PmtMtd` - immer `TRF` bei pain.001
- `ReqdExctnDt` - gewünschtes Ausführungsdatum
- `Dbtr` / `DbtrAcct` / `DbtrAgt` - Auftraggeber, Belastungskonto (IBAN), Bank
- `ChrgBr` - Gebührenregelung (SLEV, SHAR, DEBT)

**Level C - Credit Transfer Transaction (`CdtTrfTxInf`)**
Die einzelne Zahlung. Pro B-Level sind beliebig viele C-Level-Einträge möglich.
- `EndToEndId` - durchgängige Referenz bis zum Empfänger
- `InstdAmt Ccy="..."` - Betrag mit ISO-Währungscode
- `Cdtr` / `CdtrAcct` / `CdtrAgt` - Empfänger, Empfängerkonto, Empfängerbank
- `RmtInf` - Mitteilung (`Ustrd` unstrukturiert oder `Strd` strukturiert)

### 4.2 Strukturbaum

```
Document
└── CstmrCdtTrfInitn
    ├── GrpHdr                          ← Level A (1x pro Datei)
    │   ├── MsgId
    │   ├── CreDtTm
    │   ├── NbOfTxs
    │   ├── CtrlSum
    │   └── InitgPty
    └── PmtInf                          ← Level B (1..n)
        ├── PmtInfId
        ├── PmtMtd (TRF)
        ├── ReqdExctnDt
        ├── Dbtr / DbtrAcct / DbtrAgt
        └── CdtTrfTxInf                 ← Level C (1..n)
            ├── PmtId (InstrId, EndToEndId)
            ├── Amt (InstdAmt)
            ├── Cdtr / CdtrAcct / CdtrAgt
            └── RmtInf (Strd / Ustrd)
```

## 5. Schweizer Zahlungsarten in pain.001

Je nach Zahlungstyp müssen unterschiedliche Felder gefüllt werden.

| Zahlungsart | Anwendung |
|---|---|
| Type 1 | QR-Rechnung mit QR-IBAN und QR-Referenz (ehem. ESR/BESR) |
| Type 2.2 | QR-Rechnung mit IBAN und Creditor Reference (SCOR) |
| Type 3 | SEPA-Überweisung (EUR im SEPA-Raum) |
| Type 4 | IBAN-Überweisung im Inland (CHF/EUR) |
| Type 5 | Auslandzahlung in Fremdwährung |
| Type 6 | Fremdwährungszahlung im Inland |

## 6. Minimalbeispiel pain.001

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.09">
  <CstmrCdtTrfInitn>
    <GrpHdr>
      <MsgId>MSG-20260422-0001</MsgId>
      <CreDtTm>2026-04-22T09:30:47</CreDtTm>
      <NbOfTxs>1</NbOfTxs>
      <CtrlSum>1250.00</CtrlSum>
      <InitgPty>
        <Nm>Muster AG</Nm>
      </InitgPty>
    </GrpHdr>
    <PmtInf>
      <PmtInfId>PMT-2026-04-22-001</PmtInfId>
      <PmtMtd>TRF</PmtMtd>
      <NbOfTxs>1</NbOfTxs>
      <CtrlSum>1250.00</CtrlSum>
      <ReqdExctnDt>
        <Dt>2026-04-24</Dt>
      </ReqdExctnDt>
      <Dbtr>
        <Nm>Muster AG</Nm>
      </Dbtr>
      <DbtrAcct>
        <Id>
          <IBAN>CH9300762011623852957</IBAN>
        </Id>
      </DbtrAcct>
      <DbtrAgt>
        <FinInstnId>
          <BICFI>POFICHBEXXX</BICFI>
        </FinInstnId>
      </DbtrAgt>
      <CdtTrfTxInf>
        <PmtId>
          <EndToEndId>RECHNUNG-2026-456</EndToEndId>
        </PmtId>
        <Amt>
          <InstdAmt Ccy="CHF">1250.00</InstdAmt>
        </Amt>
        <Cdtr>
          <Nm>Lieferant GmbH</Nm>
        </Cdtr>
        <CdtrAcct>
          <Id>
            <IBAN>CH4431999123000889012</IBAN>
          </Id>
        </CdtrAcct>
        <RmtInf>
          <Strd>
            <CdtrRefInf>
              <Tp><CdOrPrtry><Prtry>QRR</Prtry></CdOrPrtry></Tp>
              <Ref>210000000003139471430009017</Ref>
            </CdtrRefInf>
          </Strd>
        </RmtInf>
      </CdtTrfTxInf>
    </PmtInf>
  </CstmrCdtTrfInitn>
</Document>
```

## 7. Wichtige Validierungsregeln

- `NbOfTxs` und `CtrlSum` im Group Header müssen mit der Summe aller `PmtInf`-Blöcke übereinstimmen.
- IBAN-Prüfziffer muss korrekt sein. QR-IBANs erkennt man an der IID im Bereich 30000-31999.
- Bei QR-Referenz (`QRR`): exakt 27 Stellen inkl. Prüfziffer (Modulo 10 rekursiv).
- Bei Creditor Reference (`SCOR`): gemäss ISO 11649.
- Umlaute und Sonderzeichen gemäss Swiss Character Set der SIX (Latin-1-Basis).
- Das XML muss UTF-8-kodiert sein.
- Die `MsgId` muss pro Einlieferung bei der Bank eindeutig sein.

## 8. Prozessfluss

```
Buchhaltung/ERP          Bank                    Empfängerbank
     │                     │                            │
     │  pain.001           │                            │
     ├────────────────────▶│                            │
     │                     │  pacs.008 (Interbank)      │
     │  pain.002 (Status)  ├───────────────────────────▶│
     │◀────────────────────┤                            │
     │                     │                            │
     │  camt.054 (Belastung)                            │
     │◀────────────────────┤                            │
     │                     │                            │
     │  camt.053 (Kontoauszug)                          │
     │◀────────────────────┤                            │
```

## 9. Referenzen und Quellen

**Offizielle Dokumentation:**
- SIX Download Center: https://www.six-group.com/en/products-services/banking-services/payment-standardization/downloads-faq/download-center.html
- Swiss Payment Standards (Business Rules)
- Implementation Guidelines "Customer Credit Transfer Initiation (pain.001)"
- Implementation Guidelines "Customer Direct Debit Initiation (pain.008)"
- Implementation Guidelines "Customer Payment Status Report (pain.002)"
- Implementation Guidelines "Bank-to-Customer Messages (camt.052, camt.053, camt.054)"
- Schweizer Implementation Guidelines: QR-Rechnung

**Relevante Organisationen:**
- SIX Group / SIX Interbank Clearing (Herausgeber der SPS)
- European Payments Council (SEPA-Regelwerk)
- SWIFT (MT- und pacs-Formate)
- ISO (ISO 20022 Basisstandard)

## 10. Zusammenfassung auf einen Blick

| Zweck | Format | Richtung |
|---|---|---|
| Überweisungsauftrag | pain.001 | Kunde → Bank |
| Lastschriftauftrag | pain.008 | Kunde → Bank |
| Statusrückmeldung | pain.002 | Bank → Kunde |
| Kontoauszug (tagesfertig) | camt.053 | Bank → Kunde |
| Untertägiger Bericht | camt.052 | Bank → Kunde |
| Einzelbuchungsavis | camt.054 | Bank → Kunde |
| Zahlungsavis (QR) | QR-Rechnung | Rechnungssteller → Zahler |

---

*Diese Referenz gibt einen Überblick. Für die technische Umsetzung sind immer die aktuellen Implementation Guidelines von SIX sowie die spezifischen Vorgaben der jeweiligen Hausbank massgebend.*
