import sympy #kniznica na generovanie p a q prvocisel
from sympy import isprime #kniznica na overnie prvociselnosti
import math #kniznica na matematicke operacie ako gcd, sqrt a podobne
import random #kniznica na generovanie nahodnych cisel
import time #kniznica na pracovanie s casom

#Generovanie RSA
def RsaGen(bitLength): #zistenie rozsahov pre generovanie prvocisel podla zadanej hodnotu bitLength
    if(bitLength==16):
        min=0
        max=2**16
    elif(bitLength in range(17,33)):
        min=2**16
        max=2**32
    elif(bitLength in range(33,65)):
        min=2**32
        max=2**64    
    p=sympy.randprime(min, max) #generovanie p a q
    q=sympy.randprime(min, max)
    print ("p=%s q=%s"%(p,q))
    n=p*q
    euler=(p-1)*(q-1)

    while True:
        privateKey = random.randint(2, n-1)  
        if math.gcd(privateKey, euler) == 1:
            break
    publicKey = pow(privateKey, -1, euler)
    print ("verejny kluc=%s privatny kluc=%s"%(publicKey, privateKey))
    return (publicKey,privateKey, n,min)

#Desifrovanie
def Decrypt(cipherText,newPrivateKey,n,plainText):
    decryptedText=pow(cipherText,newPrivateKey,n)
    decryptedTextBytes = decryptedText.to_bytes((plainText.bit_length()+7) // 8, byteorder="big")
    decryptedText = decryptedTextBytes.decode("utf-8")
    print("Desifrovany text je: "+decryptedText)   
    return 0
#Brute force
def BruteForce(n,publicKey):
    max = int(math.sqrt(n))    #zistenie najvyssieho mozneho cisla, ktore deli n
    min = 2
    if max%2==0:    #uprava maxima, aby nebolo parne
        max=max+1
    start = time.perf_counter()
    for prime in range (max,min,-2 ): 
        if(n%prime==0): #testovanie, ci testovane cislo deli n bez zvisku
            stop = time.perf_counter()
            print("\nZistenie prvocisel trvalo:",stop-start)
            q=int(n/prime)
            p=int(prime)
            privateKey = pow(publicKey, -1, (p - 1) * (q - 1))  #zostavenie kluca
            print ("Zisteny privatny kluc je: "+str(privateKey))
            methodTimes.append(("Brute Force", stop - start))
            return privateKey
    return 0
#Fermatova faktorizacia
def fermatFactorization(n,publicKey):
    t=math.isqrt(n)+1   #zistenie pociatocnej hodnoty
    num=0
    a=t
    res=math.isqrt((a**2)-n)
    start = time.perf_counter()
    while((res**2)!=(a**2)-n): #hladanie kongurencie mod n
        num=num+1
        a=t+num
        res=math.isqrt((a**2)-n)
    stop = time.perf_counter()
    print("\nZistenie prvocisel trvalo:",stop-start)
    b=res
    p=a+b
    q=a-b
    privateKey = pow(publicKey, -1, (p - 1) * (q - 1)) #zostavenie kluca
    print ("Zisteny privatny kluc je: "+str(privateKey))
    methodTimes.append(("Fermatova factorizacia", stop - start))
    return privateKey   

# Pollard Rho    
def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a
def pollardRho(n):
    factors = []
    start = time.perf_counter()
    while n > 1:
        if n == 1:
            factors.append(1)
            break
        x = 2
        y = 2
        d = 1
        f = lambda x: (x**2 + 1) % n    # Definovanie funkcie na generovanie pseudonahodnych cisel
        while d == 1:   # Hlavný cyklus algoritmu
            x = f(x)   
            y = f(f(y)) 
            d = gcd(abs(x - y), n)  # Spocitanie najvacsieho spolocneho delitela

        if d == n:  # Pokial je d rovnake ako n, znamena to, ze faktorizacia zlyhala
            factors.append(n)
            break
        else:
            factors.append(d)    # Inak vrati jeden z netrivialnych delitelov n
            n //= d
    p=factors[0]
    q=factors[1]
    newPrivateKey = pow(publicKey, -1, (p - 1) * (q - 1))
    stop = time.perf_counter()
    print("Zistenie prvocisel trvalo:"+str(stop-start))
    print("Zisteny privatny kluc je:"+str(newPrivateKey))
    methodTimes.append(("Pollard Rho", stop - start))
    return newPrivateKey


bitLength=0 
while(bitLength not in range(16,65)):   #nacitanie velkosti prvocisel aj s ochranou proti zadaniu neplatnych hodnot
    try:
        bitLength=int(input("Zadajte pozadovanu dlzku prvocisel(od 16b do 64b): "))
        if(bitLength not in range(16,65)):
            print("Cislo musi byt v rozsahu 16-64!")
    except:
        print("Zadali ste neplatnu hodnotu!")
publicKey,privateKey,n,min=RsaGen(bitLength)
plainText=""
while(plainText ==""):
    plainText=input("Zadajte text na zasifrovanie: ")   #ziskanie plaintextu od uzivatela
    if min==0 and len(plainText)>4:
        plainText=""
        print("Mozte zadat maximalne 4 znaky")
    if min==2**16 and len(plainText)>7:
        plainText=""
        print("Mozte zadat maximalne 7 znakov")
    if min==2**32 and len(plainText)>14:
        plainText=""
        print("Mozte zadat maximalne 14 znakov")    

plainText=int.from_bytes(plainText.encode("utf8"),byteorder="big")  #premena plaintextu na ciselnu hodnotu pre moznost sifrovania

#Sifrovanie
cipherText= pow(plainText, publicKey, n)
print("Sifrovany text je: "+str(cipherText))
methodTimes = []
while True: #cyklus pre menu
    choice=0
    print("\nMENU\n1.)Brute force\n2.)Fermatova faktorizacia\n3.)Pollardov rho algoritmus\n4.)Zobrazit zoradene metody\n5.)Exit ")
    while choice not in range(1,7):
        try:
            choice=int(input("Vyberte moznost: "))  #vyber v menu aj s ochranou proti neplatnym vstupom
            if(choice not in range(1,7)):
                print("Cislo musi byt v rozsahu 1-6!")
        except:
            print("Zadali ste neplatnu hodnotu!")
    if choice==1:
        newPrivateKey=BruteForce(n, publicKey)  #utok hrubou silou
        try:
            Decrypt(cipherText,newPrivateKey,n,plainText)
        except Exception as e:
            print("Nastala chyba a nepodarilo sa desifrovat: ",e)
    elif choice==2:
        newPrivateKey=fermatFactorization(n,publicKey)  #utok fermatovou faktorizaciou
        try:
            Decrypt(cipherText,newPrivateKey,n,plainText)
        except Exception as e:
            print("Nastala chyba a nepodarilo sa desifrovat: ",e)
    elif choice==3: #utok pollard rho algorytmom
        newPrivateKey=pollardRho(n)
        try:
            Decrypt(cipherText,newPrivateKey,n,plainText)
        except Exception as e:
            print("Nastala chyba a nepodarilo sa desifrovat: ",e)
    elif choice==4:#porovnanie vsetkych casov utokov
        methodTimes.sort(key=lambda x: x[1])
        print("metody podla casu:")
        for method, timeTaken in methodTimes:
            print(f"{method}: {timeTaken} sekund")
    if choice ==5: #ukoncenie programu
        break
