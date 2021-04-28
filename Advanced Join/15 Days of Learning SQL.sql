select 
submission_date ,(
    SELECT COUNT(distinct hacker_id)  
    FROM Submissions s2  
    WHERE s2.submission_date = s1.submission_date AND (SELECT COUNT(distinct s3.submission_date)     FROM      Submissions s3 WHERE s3.hacker_id = s2.hacker_id AND s3.submission_date < s1.submission_date)          = dateDIFF(s1.submission_date , '2016-03-01')) ,(
    select hacker_id  from submissions s2 where s2.submission_date = s1.submission_date 
    group by hacker_id order by count(submission_id) desc , hacker_id limit 1) as s3,(
    select name from hackers where hacker_id = s3)
from 
(select distinct submission_date from submissions) s1
group by submission_date



/*    NEW SOLUTION(WORKED)   */ 

SELECT inl.*,
       name
FROM
  (SELECT t2.submission_date,
          t1.ucn,
          min(t2.hacker_id) hacker_id
   FROM
     (SELECT submission_date,
             count(DISTINCT hacker_id) ucn
      FROM
        (SELECT s.*,
                dense_rank() over(
                                  ORDER BY submission_date) AS date_rank,
                dense_rank() over(PARTITION BY hacker_id
                                  ORDER BY submission_date) AS hacker_rank
         FROM submissions s)
      WHERE hacker_rank=date_rank
      GROUP BY submission_date,
               date_rank,
               hacker_rank)t1,
     (SELECT submission_date,
             max(cn) mcn
      FROM
        (SELECT submission_date,
                hacker_id,
                count(*) cn
         FROM submissions
         GROUP BY submission_date,
                  hacker_id)
      GROUP BY submission_date)t3,
     (SELECT submission_date,
             hacker_id,
             count(*) cn
      FROM submissions
      GROUP BY submission_date,
               hacker_id)t2
   WHERE t1.submission_date=t2.submission_date
     AND t2.submission_date=t3.submission_date
     AND t2.cn=t3.mcn
   GROUP BY t2.submission_date,
            t1.ucn) inl,
     hackers h
WHERE inl.hacker_id=h.hacker_id
ORDER BY 1;
