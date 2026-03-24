from django.core.management.base import BaseCommand
from django.core.management import call_command
import os
import shutil
from django.contrib import admin
from django.conf import settings

class Command(BaseCommand):
    help = 'Fix static files by copying Django admin static files'

    def handle(self, *args, **options):
        self.stdout.write('🔧 Fixing static files...')
        
        # Clear existing static files
        if os.path.exists(settings.STATIC_ROOT):
            shutil.rmtree(settings.STATIC_ROOT)
            self.stdout.write('Cleared existing static files')
        
        # Create static root
        os.makedirs(settings.STATIC_ROOT, exist_ok=True)
        
        # Copy Django admin static files
        source = os.path.join(os.path.dirname(admin.__file__), 'static', 'admin')
        dest = os.path.join(settings.STATIC_ROOT, 'admin')
        
        if os.path.exists(source):
            # Remove dest if exists
            if os.path.exists(dest):
                shutil.rmtree(dest)
            # Copy
            shutil.copytree(source, dest)
            css_count = len(os.listdir(os.path.join(dest, 'css')))
            self.stdout.write(self.style.SUCCESS(f'✅ Copied admin static files ({css_count} CSS files)'))
        else:
            self.stdout.write(self.style.ERROR(f'❌ Source not found: {source}'))
        
        # Run collectstatic
        self.stdout.write('Running collectstatic...')
        call_command('collectstatic', interactive=False, clear=True, verbosity=0)
        
        self.stdout.write(self.style.SUCCESS('✅ Static files fixed!'))
