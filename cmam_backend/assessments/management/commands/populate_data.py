from django.core.management.base import BaseCommand
from assessments.models import Assessment
import random
from datetime import datetime, timedelta

class Command(BaseCommand):
    help = 'Populate database with sample CMAM assessment data'

    def add_arguments(self, parser):
        parser.add_argument('--count', type=int, default=50, help='Number of assessments to create')

    def handle(self, *args, **options):
        count = options['count']
        
        pathways = ['SC_ITP', 'OTP', 'TSFP', 'None']
        statuses = ['SAM', 'MAM', 'Healthy']
        appetites = ['good', 'poor', 'failed']
        
        self.stdout.write('Creating sample assessments...')
        
        for i in range(count):
            pathway = random.choice(pathways)
            
            if pathway == 'SC_ITP':
                status = 'SAM'
                muac_mm = random.randint(90, 110)
                edema = random.choice([0, 1])
                appetite = random.choice(['poor', 'failed'])
                danger_signs = 1
                z_score = random.uniform(-4.5, -3.0)
                confidence = random.uniform(0.85, 0.98)
            elif pathway == 'OTP':
                status = 'SAM'
                muac_mm = random.randint(95, 112)
                edema = 0
                appetite = 'good'
                danger_signs = 0
                z_score = random.uniform(-3.5, -3.0)
                confidence = random.uniform(0.88, 0.95)
            elif pathway == 'TSFP':
                status = 'MAM'
                muac_mm = random.randint(115, 124)
                edema = 0
                appetite = 'good'
                danger_signs = 0
                z_score = random.uniform(-2.9, -2.0)
                confidence = random.uniform(0.90, 0.97)
            else:
                status = 'Healthy'
                muac_mm = random.randint(125, 160)
                edema = 0
                appetite = 'good'
                danger_signs = 0
                z_score = random.uniform(-1.9, 1.0)
                confidence = random.uniform(0.92, 0.99)
            
            assessment = Assessment.objects.create(
                child_id=f'CH{str(i+1).zfill(6)}',
                sex=random.choice(['M', 'F']),
                age_months=random.randint(6, 59),
                muac_mm=muac_mm,
                edema=edema,
                appetite=appetite,
                danger_signs=danger_signs,
                muac_z_score=round(z_score, 2),
                clinical_status=status,
                recommended_pathway=pathway,
                confidence=round(confidence, 2),
                synced=True
            )
            
            days_ago = random.randint(0, 30)
            assessment.timestamp = datetime.now() - timedelta(days=days_ago)
            assessment.save()
        
        self.stdout.write(self.style.SUCCESS(f'✅ Successfully created {count} sample assessments'))
        
        total = Assessment.objects.count()
        self.stdout.write(f'\n📊 Database Statistics:')
        self.stdout.write(f'Total assessments: {total}')
        for pathway in pathways:
            count = Assessment.objects.filter(recommended_pathway=pathway).count()
            percentage = (count / total * 100) if total > 0 else 0
            self.stdout.write(f'  {pathway}: {count} ({percentage:.1f}%)')
