; SDU Bilgisayar Muhendisligi Bolumu
; 
; Mikroislemciler dersi 1.2 ödev uygulama kodu
; 
; 28.10.2016
; Yrd. Doc. Dr. Fatih Gokce

.equ RAMEND, 0x21ff
.equ SREG, 0x3f
.equ SPL, 0x3d
.equ SPH, 0x3e
.equ PORTC, 0x08	; PORTC nin adresiyle tanimlanmasi
.equ DDRC, 0x07		; DDRC nin adresiyle tanimlanmasi
.equ PINC, 0x06		; PINC nin adresiyle tanimlanmasi
.equ PORTB,0x05		; PORTB nin adresiyle tanimlanmasi
.equ DDRB,0x04		; DDRB nin adresiyle tanimlanmasi
.equ PINB,0x03		; PINB nin adresiyle tanimlanmasi


					; 0. adresteki komut, reset sonrasinda, yani mikrodenetleyici 
					; ilk basladiginda, ilk olarak calistirilan komuttur. 
.org 0				; Program hafizasindaki 0. adrese, bir sonraki satirdaki komutun yazilmasini saglar.
	rjmp mymain		; ilk olarak calismasini istedigimiz mymaine yonlendirme amaciyla bu komutu yaziyoruz.
	

mymain:
	ldi r19,0xF0	; 0xF0=1111 0000 -> PORTB nin 1.,2.,3. ve 4. pinini input yapmak istiyoruz, o nedenle ilk 4 bit 0
	out DDRB,r19	; PortC nin data direction registeri DDRB ye r16 daki degeri yaziyoruz
	ldi r16,0xFF 	; 0x20=1111 1111 -> PORTC nin tüm. pinlerini output yapmak istiyoruz, o nedenle hepsi 1
	out DDRC,r16	; PortC nin data direction registeri DDRB ye r16 daki degeri yaziyoruz
	ldi r18,0x04
	ldi r21,0xFF	; r21 bizim ledlerin hangisinin yanı hangisinin sönük olduğunu ayarlıyoruz
	ldi r22,0xFF	; r22 register ını cp karşılaştırmaları için kullandığım üst değer
	ldi r23,0x01	; r23 register ını cp karşılaştırmaları için kullandığım alt değer
	ldi r19,0x0F	; r19 benim ledlerimin frekanslarını ayarlamak için kullandığım register
	ldi r20,0x0F	; r20 de benim ledlerimin frekanslarını ayarlamak için kullandığım register
	ldi r24,0x00	
	ldi r25,0xFF
	sbi PORTB,0		; PortB nin pull-up dirençlerini aktifleştirmek için 0. pini set ediyoruz yani 1 yapıyoruz
	sbi PORTB,1		; PortB nin pull-up dirençlerini aktifleştirmek için 1. pini set ediyoruz yani 1 yapıyoruz
	sbi PORTB,2		; PortB nin pull-up dirençlerini aktifleştirmek için 2. pini set ediyoruz yani 1 yapıyoruz
	sbi PORTB,3		; PortB nin pull-up dirençlerini aktifleştirmek için 3. pini set ediyoruz yani 1 yapıyoruz
mainloop:				; bizim ana döngümüz işlerin asıl gerçekleştiği yer
	push r21			; r21 in içindeki değere stack a attık ki değer değişmeden kullanalım
	ldi r21,0x00		; r21 in içine ledleri söndermek için 0000 0000 değerini aktardık
	out PORTC,r21		; PortC ye r21 i attık
	call frekans		; ledlerin parlaklığını ayarlayacak metodumuz u çağırdık
	pop r21				; stack a attığımız veriyi r21 e geri yükledik
	out PORTC,r21		; ve PortC ye r21 tekrar aktardık ve ledlerimin yanmasını sağladık
	
	; yukarıdaki işlemler ile ledlerimizin frekansını ayarladık
	
	rjmp oku			;buttonlara basıldı mı diye kontrol ettiğimiz methot
	rjmp mainloop		; döngümüzü sonlandırmamak için mainloop a atladık
oku:
	sbis PINB,2			; bağladığımız 3. buttona basıldımı diye kontrol eder
	rjmp art			; eğer buttona basıldıysa ledlerin parlaklığını azalttığımız fonksiyona atla
	sbis PINB,3			; bağladığımız 4. buttona basıldımı diye kontrol eder
	rjmp azal			; eğer buttona basıldıysa ledlerin parlaklığını artırdığımız fonksiyona atla
	cp r20,r22			; r20 ve r22 yi karşılaştır - led parlaklığı en alt seviyede mi diye
	breq mainloop		; eşitse mainloop a dallan
	sbis PINB,0			; ilk buttona basıldımı - yanan led sayıısını azaltmak için
	rjmp sol			; eğer basıldıysa sol methotuna atla
	sbis PINB,1			; 2. buttona basıldımı - yanan led sayıısını artırmak için
	rjmp sag			
	rjmp mainloop		; basılmadıysa mainloop a git
sol:
	cp r21,r23			; sadece tek led mi yanıyor kontrol ediyoruz
	breq mainloop		; eger eşitse mainloop
	call wait			; wait methodu çağırıyoruz buttonun sadece bir kere basılmasını sağlamak için zaman gecikmesi yapıyoruz
	lsr r21				; 1 led söndürmek için r21 verilerini 1 sağa kaydır
	rjmp mainloop		; geri dön
sag:
	cp r21,r22			; ledlerin hepsi yanıyor mu diye kontrol et
	breq mainloop		; eğer yanıyorsa geri dön
	sec					; carry bitini set ediyoruz
	call wait			
	rol r21				; carry biti ile r21 içindeki değeri ekleyerek sol tarafa aktarıyoruz led i yakıyoruz
	rjmp mainloop		; geri dön
art:
	call wait			; buttona basıldıysa beklet
	cp r16,r22			; led parlaklığı en az seviyede mi kontrol et
	brne artir			; eğer değilse parlaklık seviyesini 1 kademe düşürecek methoda git
	rjmp mainloop		; geri dön
artir:
	sec					; carry bitini set ediyoruz
	cp r20,r22			
	breq mainloop
	rol r20				;led parlaklığını 1 seviye azaltıyoruz	;add r16,r18
	rol r19				;led parlaklığını 1 seviye azaltıyoruz
	rjmp mainloop		; geri dön	;add r17,r18
azal:
	call wait			; buttona basıldıysa beklet
	cp r16,r23			; led parlaklığı en üst seviyede mi kontrol et
	brne azalt			; eğer değilse parlaklık seviyesini 1 kademe artıracak methoda git
	rjmp mainloop		; geri dön
azalt:
	cp r20,r23
	breq mainloop
	lsr r20				; parlaklıgı artırmak için kademeyi 1 düşürüyoruz 		
	lsr	r19				; parlaklıgı artırmak için kademeyi 1 düşürüyoruz		
	rjmp mainloop		; geri dön
frekans:
	mov r17,r20			; frekansı ayarlamak için kullandığımız r20 registerını r17 ye aktarıyoruz
	mov r16,r19			; aynı şekilde r19 r16 ya 
_w1:					; bu fonksiyon bizim led parlaklığını ayarladığımız döngümüzü yapıyor
	dec r17				; r17 nin içindeki değeri bir azalt
	brne _w1			; eğer 0 değilse _w1 mothotuna git
	dec r16				; aynı şekilde r16 ya bak
	brne _w1
	ret					; geri dön
wait:				; 700ms lik bekleme saglayan fonksiyonumuz
   push r16			; mainloop icerisinde kullandigimiz r16 ve r17 nin degerlerini wait icinde de kullanmak istiyoruz.
   push r17			; bu nedenle push komutunu kullanarak bu registerlarin icindeki degerleri yigina kaydediyoruz
   
   ldi r16,0x0C 	; 0x1200000 kere dongu calistirilacak
   ldi r17,0x00 	; ~12 milyon komut cycle i surecek
   ldi r18,0x00 	; 16Mhz calisma frekansi icin yaklaşık ~1 s zaman gecikmesi elde edilecek
_w0:
	push r21
	ldi r21,0x00		
	out PORTC,r21
	pop r21
	out PORTC,r21
	dec r18			; r18 deki degeri 1 azalt
	brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan
	dec r17			; r17 deki degeri 1 azalt
	brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan
	dec r16			; r16 daki degeri 1 azalt
	brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan

	pop r17			; fonksiyondan donmeden once en son push edilen r17 yi geri cek
	pop r16			; r16 yi geri cek
   
   ret				; fonksiyondan geri don
.END

