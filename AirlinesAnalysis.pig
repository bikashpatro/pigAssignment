/*Load Data
----------------------------------------------------- */
A = load '/PigData/airports_mod.dat' using PigStorage(',') as (Airportid:int, Airportname:chararray, city:chararray, country:chararray, IATA_FAA:chararray, ICAO:chararray, Latitude:double , Longitude:double, Altitude: int,Timezone:int ,DST:chararray ,timeZone:chararray);
B = foreach A generate $1 as Airport_name,$3 as country, $4 as IATA_FAA;

A1 = load '/PigData/Final_airlines' using PigStorage(',') as (Airlines:int, Nameofairlines:chararray,Alias:chararray, IATA:chararray, ICAO:chararray, Callsign:chararray, CountryOrTerritory:chararray, Active:chararray);
B1 = foreach A1 generate $0 as Airlines, $1 as Nameofairlines,$3 as IATA, $4 as ICAO, $6 as CountryOrTerritory, $7 as Active;

A2 = load '/PigData/routes.dat' using PigStorage(',') as (Airline:chararray, Airlineid:chararray, Source_airport:chararray, Source_airport_id:int, Destination_airport:chararray, Destination_airport_id:int, Codeshare:chararray, NumofStops:int, Equipment:chararray);
B2 = foreach A1 generate $2 as Source_airport,$3 as Source_airport_id, $4 as Destination_airport,$5 as Destination_airport_id, $6 as Codeshare, $7 as NumofStops;

/*A. Find list of Airports operating in the Country India
----------------------------------------------------- */

RA1 = filter B by (country == 'India');
RA2 = group RA1 by Airport_name;
RA3 = foreach RA2 generate group;

STORE RA3 INTO '/PigData/output/A.ListofAirportOperatingintheCountryIndia';

/*B. Find the list of Airlines having zero stops
--------------------------------------------*/
RB1 = filter A2 by NumofStops==0;
RB2 = foreach RB1 generate Source_airport, NumofStops;
RB3 = join RB2 by Source_airport,B1 by ICAO;
RB4 = group RB3 by Nameofairlines;
RB5 = foreach RB4 generate group;
STORE RB5 INTO '/PigData/output/B.ListofAirliesHavingzerostops';

/*C. List of Airlines operating with code share
------------------------------------------*/
RC1 = filter A2 by (Codeshare =='Y');
RC2 = group RC1 by Source_airport;
RC3 = foreach RC2 generate group;
RC4 = join RC3 by $0, B1 by ICAO;
RC5 = group RC4 by $2;
RC6 = foreach RC5 generate group;
STORE RC6 INTO '/PigData/output/C.AirLinesOperatingWithCodeShare';

/*D. Which country (or) territory having highest Airports
----------------------------------------------------*/
RD1 = group B by country;
RD2 = foreach RD1 generate group, COUNT(B.Airport_name);
RD3 = ORDER RD2 BY $1 DESC;
RD4 = limit RD3 1;
dump RD4;
STORE RD4 INTO '/PigData/output/D.countryOrTerritoryhavingHighestAirport';

/*E. Find the list of Active Airlines in United state
---------------------------------------------------*/
RE1 = filter B1 by (CountryOrTerritory == 'United States') and (Active == 'Y');
RE2 = foreach RE1 generate $1 as ActiveAirlinesinUS;
RE3 = order RE2 by $0;

STORE RE3 INTO '/PigData/output/E.ListOfActiveAirlinesinUnitedState';
