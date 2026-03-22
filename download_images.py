import urllib.request
import os

images = {
    "main_tracker.png": "https://lh3.googleusercontent.com/aida/ADBb0uicvwwknVFn8PrZ6EkdGeh0LEMfEvBd5er5ts0Zx1esgeoyNiIP8g0fYZXiOSkilMKN1R_OwVwvykKDgcq4SJXiFpjTAUL6vdoBlyVpPNCq-aunXRxJuzVRZKC6fFis2KIyYhf3jm5i9Va3ysGzBZs-7BLOE5BAb2X-BuG9wChsf00Em388SD5gP4Dyv11WA1Otu9p0AVu6qcJdg4itpoUnK_ITXZ__fE0Ir3Ara42ASVTJWtQ4A_3mkQo5",
    "daily_reflections_journal.png": "https://lh3.googleusercontent.com/aida/ADBb0ui2dKAHg88de2nX2J-X8fPJGbvw68t2yzBjiyY-9rSfxPy8d1FF2PjrpchpLRtLYJNLiRQwdOxvCjptkpRkAVQVyeJJzjdJeE5J5fwdFDUgIY_QenWYe94is9pMxWj4XNBwuqcmc0yMWVq5Z2xBd_Ry6sG7eRGrAqXxSFY7r-qTujKDsBjKPcW8d2E-bvZAx1lZWGHtg3wcW9kRq1C_0Uf7nEIL7zGHd8K_fmjobJ5fphx6o_79kxZ-PM2c",
    "prayer_dashboard_coming_soon.png": "https://lh3.googleusercontent.com/aida/ADBb0uiWLuGSC3651lP5ZIKlrf-r7tvxiWxHyNG7uip95A03BZMcaFYoXo8aljmTegG25E6HL-DGvyJSqJe0gLdvZgjtURftn1NHE8nbk9OzHBaT0vtGpMTGwTHrr8-SwRV9Wr5RShnPDmlXQ7JVS3QGICU0rNNtXvpLcPpC5bJljtqkA8O4wbU3NItDY7AQe1FqVhp5eJG5vNvlsgQLqLwrBgv-qzIGrR_cVjpt5Ceu4VBb8EKYNKtokG5cFCGv",
    "main_tracker_dark.png": "https://lh3.googleusercontent.com/aida/ADBb0uhEzs-K__8XnJEYbcU03PadhQbQC-lvlFqNi9KXLpdbw4oU7O4c8lAUJUMC91iESfdRlCXll4Gg-EAE-g2BFUioNwxzs2ON_WA33mK6ORl2VL9yhdEoboPogEd4_wR5HqbPnqIwwiaOfB20PQS7bjBiXWUkp8_cQHQM-nVh394qODokkjoSuz-GugC57b9ce9lAAFLrnSPd_OspjxETdTVm_gG-jDJTmxk-sCyh_FItn0cHZflvSwujYVY",
    "journal_dark.png": "https://lh3.googleusercontent.com/aida/ADBb0uh62gF_UNepAWwP5klNVigwkcv_bzuSskcTVjiln14TP13PBFZzQxPItwTJpYGDsF6mZnD4oWrU3P-VxAFIGxJRTAODT5nGGQniuZSuuf54H7UWfp_smal3XbgJOpkEkEl5ncca-u-uI7vr91q6fCwKgVe01s0Sxv8H4AeFkkIh-HgGOo8w26ZSnQEZp6PsT2mTR0HmE7IAEK2oypPXkIH9bEaX1fFOTnqDzkEUSa7xYINscVPoLXCKV-di",
    "notification_settings.png": "https://lh3.googleusercontent.com/aida/ADBb0uhpkj3tzVy6EbtsmdxYm1teVM7QoPHRO8tMRAqJbeKmdm7QSzwS44j-VVSL2tN5EIGxLopa13n-EYhMQYV97EYtiYpGPTEFlMoQUOr6pPmv-qj7no9rzGGx7oTyJU_ArXVR_3MVS5Rh6ZgwplnsT5tjOzep-5Q40G-FN6PKjQ5l4H0B7kTsJY4B3wkFQYPWyhJiSDCPqIA6BA1R4QOB3BxD-7B0IqHSu2xVZhPEcNNWym6XfatiZvp4C0s"
}

os.makedirs("designs", exist_ok=True)
for name, url in images.items():
    print(f"Downloading {name}...")
    try:
        urllib.request.urlretrieve(url, os.path.join("designs", name))
    except Exception as e:
        print(f"Failed to download {name}: {e}")
print("Done!")
