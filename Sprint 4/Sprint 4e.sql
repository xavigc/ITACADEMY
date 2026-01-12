SELECT card_id, 
       CASE 
           WHEN SUM(CASE WHEN rank_numero = 3 THEN 1 ELSE 0 END) > 0 THEN 0
           ELSE 1
       END AS estat
FROM (
    SELECT card_id,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions
    WHERE declined = 1
) AS ultims
GROUP BY card_id;



SELECT card_id,
       CASE 
           WHEN SUM(CASE WHEN rank_numero = 3 THEN 1 ELSE 0 END) > 0 THEN 0
           ELSE 1
       END AS estat
       FROM (
SELECT card_id, max(declined), max(rank_numero) rank_numero from(
    SELECT card_id, declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions) a
--    WHERE rank_numero=3 
GROUP BY card_id,declined) b
GROUP BY card_id
;

SELECT card_id,count(*) FROM(


    SELECT card_id,declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions
) A
    WHERE rank_numero =3
GROUP BY card_id
having count(*) =1 ;


SELECT card_id, IF(max_declined=1, 1, 0) as estat FROM

(SELECT card_id, MAX(declined) max_declined FROM
    (SELECT card_id,declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions) ultims
    WHERE  rank_numero <=3) 
GROUP BY card_id) declinedornot
;


-- CcS-4878
-- SUMAR declined si =3 desactivada si no activada
select * from
(SELECT card_id,declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions) a
    WHERE  rank_numero <=3;
    
    
SELECT card_id, IF(sum(declined)=3,1,0) AS inactiu FROM
(SELECT card_id,declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY date_tx DESC) AS rank_numero
    FROM transactions) a
    WHERE  rank_numero <=3
GROUP BY card_id;

    