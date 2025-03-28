// import_data.dart
const String sampleCsvData = """
EnglishName,DisplayName,SearchingName,BuyPricePerUnit,SellPricePerUnit,Unit,ExpireDate,AddedDate,InitialQuantity,QuantityLeft,Frequency,DiscountQuantityLevel1,DiscountQuantityLevel2,DiscountValueLevel1,DiscountValueLevel2,DiscountPercentLevel1,DiscountPercentLevel2
Sugar,සීනි,Sini,150.0,170,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,300.0,300.0,0,null,null,null,null,null,null
Salt,ලුණු,Lunu,50.0,60,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,200.0,200.0,0,null,null,null,null,null,null
Tea,තේ,The,500.0,550,kg,2026-04-30T00:00:00.000,2024-10-28T00:00:00.000,100.0,100.0,0,null,null,null,null,null,null
Milk,කිරි,Kiri,120.0,140,liter,2024-11-05T00:00:00.000,2024-10-28T00:00:00.000,250.0,250.0,0,null,null,null,null,null,null
Eggs,බිත්තර,Biththara,300,350,dozen,2024-11-02T00:00:00.000,2024-10-28T00:00:00.000,150.0,150.0,0,null,null,null,null,null,null
Bread,පාන්,Paan,80.0,100,loaf,2024-10-30T00:00:00.000,2024-10-28T00:00:00.000,180.0,180.0,0,null,null,null,null,null,null
Cooking Oil,තෙල්,Thel,400,450,liter,2025-12-31T00:00:00.000,2024-10-28T00:00:00.000,120.0,120.0,0,null,null,null,null,null,null
Potatoes,අල,Ala,60.0,70,kg,2024-11-10T00:00:00.000,2024-10-28T00:00:00.000,300.0,300.0,0,null,null,null,null,null,null
Onions,ළූනු,Loonu,70.0,80,kg,2024-11-15T00:00:00.000,2024-10-28T00:00:00.000,250.0,250.0,0,null,null,null,null,null,null
Tomatoes,තක්කාලි,Thakkali,100.0,120,kg,2024-11-08T00:00:00.000,2024-10-28T00:00:00.000,220.0,220.0,0,null,null,null,null,null,null
Chicken,කුකුළු මස්,KukulMas,800.0,900,kg,2024-11-20T00:00:00.000,2024-10-28T00:00:00.000,100.0,100.0,0,null,null,null,null,null,null
Beef,බීෆ්,Beef,1500.0,1600,kg,2024-11-25T00:00:00.000,2024-10-28T00:00:00.000,80.0,80.0,0,null,null,null,null,null,null
Fish,මාළු,Malu,500.0,550,kg,2024-11-18T00:00:00.000,2024-10-28T00:00:00.000,200.0,200.0,0,null,null,null,null,null,null
Coconut,පොල්,Pol,50.0,60,piece,2025-01-15T00:00:00.000,2024-10-28T00:00:00.000,300.0,268.0,7,null,null,null,null,null,null
Lentils,දාල,Daala,250.0,270,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,150.0,150.0,0,null,null,null,null,null,null
Turmeric,කහ,Haldi,200.0,220,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,100.0,100.0,0,null,null,null,null,null,null
Cumin,ජිරා,Jira,300.0,330,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,80.0,80.0,0,null,null,null,null,null,null
Flour,පාන් පිටි,PaanPiti,180.0,200,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,200.0,195.0,1,null,null,null,null,null,null
Baking Powder,බේකින් පවුඩර්,BakingPowder,150.0,170,pack,2025-06-30T00:00:00.000,2024-10-28T00:00:00.000,100.0,100.0,0,null,null,null,null,null,null
Tea Powder,තේ පෝඩ,TayPoda,500.0,550,kg,2025-10-28T00:00:00.000,2024-10-28T00:00:00.000,120.0,120.0,0,null,null,null,null,null,null
""";
